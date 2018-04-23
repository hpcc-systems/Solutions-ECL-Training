IMPORT STD;

taxi_ds := DATASET('~training-samples::taxi::in::yellow_tripdata_2015.csv', 
                   {STRING line}, CSV(HEADING(1), SEPARATOR('')));


taxi_record := RECORD
    STRING line;
END;

taxi_record  trans(taxi_record in) := TRANSFORM
    SELF.line := STD.Str.toUpperCase(in.line)
END;

taxi_trans_ds := PROJECT(taxi_ds, trans(LEFT));

OUTPUT(taxi_trans_ds);

