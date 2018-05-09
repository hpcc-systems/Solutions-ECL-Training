IMPORT Taxi;
IMPORT SALT_Profile;


rawTaxiData := Taxi.Files.taxi_raw_ds;
OUTPUT(rawTaxiData, NAMED('rawTaxiDataSample'));

m := SALT_Profile.MOD_Profile(rawTaxiData); 

OUTPUT(m.AllProfiles,,Taxi.Files.taxi_data_patterns_raw_file_path, NAMED('AllProfiles'), THOR, COMPRESSED, OVERWRITE);
OUTPUT(m.Summary,ALL,NAMED('Summary'));
OUTPUT(m.InvSummary,ALL,NAMED('InvertedSummary'));
OUTPUT(m.Correlations,ALL,NAMED('Correlations'));
OUTPUT(m.optLayout,ALL,NAMED('OptimizedLayout'));




