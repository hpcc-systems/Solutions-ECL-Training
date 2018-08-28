IMPORT STD;
IMPORT Dataseers.ML AS ML;

DB(sym) := MACRO
    OUTPUT(CHOOSEN(sym, 1000), NAMED(#TEXT(sym)));
ENDMACRO;

incommingLayout := RECORD
  unsigned1 vendor_id;
  unsigned4 pickup_date;
  unsigned3 pickup_time;
  unsigned4 dropoff_date;
  unsigned3 dropoff_time;
  unsigned1 passenger_count;
  decimal10_2 trip_distance;
  decimal9_6 pickup_longitude;
  decimal9_6 pickup_latitude;
  unsigned1 rate_code_id;
  string1 store_and_fwd_flag;
  decimal9_6 dropoff_longitude;
  decimal9_6 dropoff_latitude;
  unsigned1 payment_type;
  decimal8_2 fare_amount;
  decimal8_2 extra;
  decimal8_2 mta_tax;
  decimal8_2 tip_amount;
  decimal8_2 tolls_amount;
  decimal8_2 improvement_surcharge;
  decimal8_2 total_amount;
 END;


dsTaxi := DATASET('~training-samples::taxi::out::yellow_tripdata_clean.thor',incommingLayout, THOR);

OUTPUT(dsTaxi,NAMED('IncommingDS'));


/****************GET COUNT******************/

getCount := COUNT(dsTaxi);

OUTPUT(getCount,NAMED('CountIncommingDS'));


/****************DEDUP Dataset*******************/
sortRes    := SORT(dsTaxi,WHOLE RECORD,LOCAL);

localDebup := DEDUP(sortRes,WHOLE RECORD,LOCAL);

OUTPUT(localDebup,NAMED('LocalDSDedup'));

gobalDebup := DEDUP(SORT(localDebup, RECORD), RECORD);

OUTPUT(gobalDebup,NAMED('GobalDSDedup'));

OUTPUT(COUNT(gobalDebup),NAMED('CountAfterDSDedup'));

/*********************REMOVE ADDITION FILEDS**********************************************/
getRequiredColumns := PROJECT(gobalDebup, TRANSFORM(
                        {
                            RECORDOF(dsTaxi) - {dsTaxi.vendor_id},
                        },SELF := LEFT
                        ));

OUTPUT(getRequiredColumns,NAMED('getRequiredColumns'));


/**********************BUSY PICK_UP HOUR********************************/
getBusyHours := TABLE(gobalDebup,{pickup_time,DistinctColCnt := COUNT(GROUP)},pickup_time);

MostBusyHour :=getBusyHours(DistinctColCnt =  MAX(getBusyHours,DistinctColCnt));  

OUTPUT(MostBusyHour,NAMED('MostBusyHour'));

/*******************POPULAR PICK_UP LOCATION********************************/
getPopularLocation := TABLE(gobalDebup,
                            {   pickup_longitude,
                                pickup_latitude,
                                DistinctColCnt := COUNT(GROUP)
                            },pickup_longitude,pickup_latitude);

MostPopularLocation :=getPopularLocation(DistinctColCnt = MAX(getPopularLocation,DistinctColCnt));  

OUTPUT(MostPopularLocation,NAMED('MostPopularLocation'));

/***********GET UNIQUE VALUE OF A COLUMN******************/
uniquePaymentTypes := TABLE(gobalDebup, {payment_type}, payment_type, MERGE);

OUTPUT(uniquePaymentTypes,NAMED('uniquePaymentTypes'));

/*************CREATING DICTIONARY AND LOOKUP VALUES************************/
paymentTypeLookUp :=   DATASET([ {1,'Cash'},
                       {2,'Mobile Token'},
                       {3,'Credit Card'},
					   {4,'Debit Card'},
					   {5,'P2P'}
				],{unsigned1 Key,STRING10 Value});

DctPayment := DICTIONARY(paymentTypeLookUp,{KEY => paymentTypeLookUp});

//ADD A COLUMN TO GET PAYMENT DESCRIPTION 
RecTaxi := RECORD 
    RECORDOF(getRequiredColumns);
    STRING10 Payment_Description;
END;

dsTaxiWithDesc := PROJECT(gobalDebup, TRANSFORM(RecTaxi,
                SELF.Payment_Description := IF(LEFT.payment_type in DctPayment,
                                            TRIM(DctPayment[LEFT.payment_type].VALUE,LEFT,RIGHT),''), 
                SELF := LEFT));

OUTPUT(dsTaxiWithDesc,NAMED('dsTaxiWithDesc'));

/***********************BASIC ML*******************************/
dsSortPerPickUPDate := SORT(TABLE(gobalDebup,{pickup_date},pickup_date),pickup_date); 

assignSequentialNumberPerDate := PROJECT(
                                    dsSortPerPickUPDate,
                                    TRANSFORM(
                                        {UNSIGNED4 Num,unsigned4 pickup_date},
                                        SELF.Num := COUNTER,
                                        SELF := LEFT
                                        ));

ML.ML_Core.Types.NumericField XF(dsTaxi L, integer C) := TRANSFORM
   SELF.id := C;
   SELF.number := assignSequentialNumberPerDate(pickup_date = L.pickup_date)[1].Num;
   SELF.value := L.fare_amount;
   SELF.wi:=1;
END;
getSequentialNumberForAll := PROJECT(dsTaxi,XF(LEFT,COUNTER));

simpleAggregations := ML.ML_Core.FieldAggregates(getSequentialNumberForAll).Simple;

OutputRec := RECORD
    RECORDOF(simpleAggregations);
    unsigned4 pickup_date;
END;
AggregateRes := JOIN(simpleAggregations,
                    assignSequentialNumberPerDate,
                    LEFT.number = RIGHT.num,
                    TRANSFORM(
                        RECORDOF(OutputRec),
                        SELF.pickup_date := RIGHT.pickup_date,
                        SELF:=LEFT
                    ),INNER);

/******************View the Result in the work unit******************************/
OUTPUT(AggregateRes,NAMED('AggregateRes'));

/****************Write a logical file that into the cluster***********************/
OUTPUT(AggregateRes,,'~GKB::taxiStatistics',CSV(SEPARATOR(','),TERMINATOR('\r\n')),OVERWRITE);

/********************DESPRAY DATA TO LANDING ZONE*********************************/
STD.File.DeSpray('~GKB::taxiStatistics','10.0.0.208',
                '/var/lib/HPCCSystems/mydropzone/gkb/taxiStatistics.csv',allowoverwrite:=FALSE);
