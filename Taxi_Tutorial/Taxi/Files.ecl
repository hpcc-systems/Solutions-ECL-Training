IMPORT STD;

EXPORT Files := MODULE
        EXPORT file_scope := '~training-samples';

        /*
            Location of raw file on the landing zone
        */

        // EXPORT taxi_lz_file_path := '/var/lib/HPCCSystems/mydropzone/yellow_tripdata_2015.csv';
        EXPORT taxi_lz_file_path := '/var/lib/HPCCSystems/mydropzone/yellow_tripdata_2015-01_10000.csv';

        /*
            Raw file layout and dataset after it is imported into Thor
        */

        EXPORT taxi_raw_file_path := file_scope + '::taxi::in::yellow_tripdata_2015.csv';

        EXPORT taxi_raw_layout := RECORD
            STRING  vendor_id;
            STRING  tpep_pickup_datetime;
            STRING  tpep_dropoff_datetime;
            STRING  passenger_count;
            STRING  trip_distance;
            STRING  pickup_longitude;
            STRING  pickup_latitude;
            STRING  rate_code_id;
            STRING  store_and_fwd_flag;
            STRING  dropoff_longitude;
            STRING  dropoff_latitude;
            STRING  payment_type;
            STRING  fare_amount;
            STRING  extra;
            STRING  mta_tax;
            STRING  tip_amount;
            STRING  tolls_amount;
            STRING  improvement_surcharge;
            STRING  total_amount;
        END;

        EXPORT taxi_raw_ds := DATASET(taxi_raw_file_path, taxi_raw_layout, CSV(HEADING(1)));

        /*
            Cleaned file layout and dataset. The cleaned file is created after cleaning the 
            raw file.
        */
    
        EXPORT taxi_clean_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_clean.thor';
        
        EXPORT taxi_clean_layout := RECORD
            UNSIGNED1   vendor_id;
            Std.Date.Date_t    pickup_date;
            Std.Date.Time_t    pickup_time;
            Std.Date.Date_t    dropoff_date;
            Std.Date.Time_t    dropoff_time;
            UNSIGNED1   passenger_count;
            DECIMAL10_2 trip_distance;
            DECIMAL9_6  pickup_longitude;
            DECIMAL9_6  pickup_latitude;
            UNSIGNED1   rate_code_id;
            STRING1     store_and_fwd_flag;
            DECIMAL9_6  dropoff_longitude;
            DECIMAL9_6  dropoff_latitude;
            UNSIGNED1   payment_type;
            DECIMAL8_2  fare_amount;
            DECIMAL8_2  extra;
            DECIMAL8_2  mta_tax;
            DECIMAL8_2  tip_amount;
            DECIMAL8_2  tolls_amount;
            DECIMAL8_2  improvement_surcharge;
            DECIMAL8_2  total_amount;
        END;

        EXPORT taxi_clean_ds := DATASET(taxi_clean_file_path, taxi_clean_layout, THOR);    

        /*
            The cleaned file is enriched to add important attributes
        */

        EXPORT taxi_enrich_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_enriched.thor';
        
        EXPORT taxi_enrich_layout := RECORD
            taxi_clean_layout;

            UNSIGNED4 record_id;

            UNSIGNED2 pickup_minutes_after_midnight;            
            UNSIGNED2 dropoff_minutes_after_midnight;

            UNSIGNED2 pickup_time_hour;
            UNSIGNED2 dropoff_time_hour;

            UNSIGNED2 pickup_day_of_week;
            UNSIGNED2 dropoff_day_of_week;
            
            UNSIGNED2 pickup_month_of_year;
            UNSIGNED2 dropoff_month_of_year;

            UNSIGNED2 pickup_year;
            UNSIGNED2 dropoff_year;

            UNSIGNED2 pickup_day_of_month;
            UNSIGNED2 dropoff_day_of_month;
        END;

        EXPORT taxi_enrich_ds := DATASET(taxi_enrich_file_path, taxi_enrich_layout, THOR);    
   
        /* 
            Create a simple attribute file that records the counts of trips daily
        */
        EXPORT taxi_analyze_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_analyze.thor';
        
        EXPORT taxi_analyze_layout := RECORD
            Std.Date.Date_t    pickup_date;
            UNSIGNED4 cnt;        
        END;

        EXPORT taxi_analyze_ds := DATASET(taxi_analyze_file_path, taxi_analyze_layout, THOR);    

        /*
            Create a training file to train a GLM for predecting trip counts for a future date
        */

        EXPORT taxi_train_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_train.thor';

        EXPORT taxi_train_layout := RECORD
            unsigned2 pickup_year;
            unsigned2 pickup_month;
            unsigned2 pickup_day_of_month;
            unsigned2 pickup_day_of_week;
            unsigned4 cnt;
        END;

        EXPORT taxi_train_ds := DATASET(taxi_train_file_path, taxi_train_layout, THOR);    
 
        /* 
            Build the GLM model for predecting traffic
        */
        // EXPORT taxi_model_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_model.thor';

        // EXPORT taxi_model_layout := RECORD

        // END;

        // EXPORT taxi_model_ds := DATASET(taxi_model_file_path, taxi_model_layout, THOR);    

        /*
           Export
        */ 

        EXPORT taxi_analysis_lz_file_path := '/var/lib/HPCCSystems/mydropzone/yellow_tripdata_analysis.csv';  
        EXPORT taxi_analyze_csv_file_path := file_scope + '::taxi::out::yellow_tripdata_analyze.csv';
END;
