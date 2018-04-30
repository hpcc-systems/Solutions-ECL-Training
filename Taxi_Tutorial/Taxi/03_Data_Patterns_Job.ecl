IMPORT Taxi;
IMPORT DataPatterns;


IMPORT Taxi;
IMPORT DataPatterns;

rawTaxiData := Taxi.Files.taxi_raw_ds;
OUTPUT(rawTaxiData, NAMED('rawTaxiDataSample'));

rawTaxiProfileResults := DataPatterns.Profile(rawTaxiData, 
             features := 'fill_rate,cardinality,best_ecl_types,lengths,patterns,modes');
OUTPUT(rawTaxiProfileResults,, 
     Taxi.Files.taxi_data_patterns_raw_file_path, OVERWRITE);