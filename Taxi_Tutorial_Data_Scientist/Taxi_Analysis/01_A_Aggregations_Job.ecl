IMPORT STD;

taxi_enrich_file_path := '~training-samples::taxi::out::yellow_tripdata_2015_enriched.thor';

taxi_enrich_ds := DATASET(taxi_enrich_file_path, RECORDOF(taxi_enrich_file_path, LOOKUP), THOR);


cnt_by_weekday_ds:= TABLE(taxi_enrich_ds, 
              {pickup_day_of_week, UNSIGNED4 cnt := COUNT(GROUP)}, 
               pickup_day_of_week); 

OUTPUT(cnt_by_weekday_ds);


