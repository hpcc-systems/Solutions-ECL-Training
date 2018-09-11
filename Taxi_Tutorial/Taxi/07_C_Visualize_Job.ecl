IMPORT Taxi;
IMPORT Visualizer;

moderec := RECORD
   string value;
   unsigned4 rec_count;
  END;

patterncountrec := RECORD
   string data_pattern;
   unsigned4 rec_count;
   string example;
  END;

patterns_layout := RECORD
  string attribute;
  unsigned4 rec_count;
  string given_attribute_type;
  decimal9_6 fill_rate;
  unsigned4 fill_count;
  unsigned4 cardinality;
  string best_attribute_type;
  DATASET(moderec) modes{maxcount(5)};
  unsigned4 min_length;
  unsigned4 max_length;
  unsigned4 ave_length;
  DATASET(patterncountrec) popular_patterns{maxcount(100)};
  DATASET(patterncountrec) rare_patterns{maxcount(100)};
 END;

patterns_ds := DATASET(Taxi.Files.taxi_data_patterns_raw_file_path, patterns_layout, THOR);

OUTPUT(patterns_ds, {attribute, cardinality}, NAMED('cardinality'));
Visualizer.Visualizer.MultiD.Bar('cardinality',, 'cardinality');
OUTPUT(patterns_ds, {attribute, fill_rate}, NAMED('fill_rate'));
Visualizer.Visualizer.MultiD.Bar('fill_rate',, 'fill_rate');

