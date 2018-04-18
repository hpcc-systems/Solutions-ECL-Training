EXPORT Files := MODULE
    EXPORT file_scope := '~training-samples';
    
    EXPORT taxi_enrich_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_enriched.thor';
    EXPORT taxi_enrich_ds := DATASET(taxi_enrich_file_path, RECORDOF(taxi_enrich_file_path, LOOKUP), THOR);
END;