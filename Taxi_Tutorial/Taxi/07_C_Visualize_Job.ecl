IMPORT Taxi;
IMPORT Visualizer;

field_identification := RECORD
   unsigned2 fldno;
   string fieldname;
  END;

length_layout := RECORD
   unsigned2 len;
   unsigned8 cnt;
   real8 pcnt;
  END;

words_layout := RECORD
   unsigned2 words;
   unsigned8 cnt;
   real8 pcnt;
  END;

character_layout := RECORD
   string1 c;
   unsigned8 cnt;
   real8 pcnt;
  END;

pattern_layout := RECORD
   string data_pattern{maxlength(200000)};
   unsigned8 cnt;
   real8 pcnt;
  END;

value_layout := RECORD
   string val{maxlength(200000)};
   unsigned8 cnt;
   real8 pcnt;
  END;

patterns_layout := RECORD(field_identification)
  unsigned8 cardinality;
  string30 minval30;
  string30 maxval30;
  real8 asnumber_minval;
  real8 asnumber_maxval;
  real8 asnumber_mean;
  real8 asnumber_var;
  DATASET(length_layout) len{maxcount(256)};
  DATASET(words_layout) words{maxcount(256)};
  DATASET(character_layout) characters{maxcount(256)};
  DATASET(pattern_layout) patterns{maxcount(300)};
  DATASET(value_layout) frequent_terms{maxcount(300)};
 END;

patterns_ds := DATASET(Taxi.Files.taxi_data_patterns_raw_file_path, patterns_layout, THOR);

OUTPUT(patterns_ds, {fieldname, cardinality}, NAMED('cardinality'));
Visualizer.MultiD.Bar('cardinality',, 'cardinality');
OUTPUT(patterns_ds, {fieldname, asnumber_mean}, NAMED('mean_value'));
Visualizer.MultiD.Bar('fill_rate',, 'fill_rate');

