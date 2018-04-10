IMPORT STD;
IMPORT Taxi;

OUTPUT(Taxi.Files.taxi_analyze_ds,,Taxi.Files.taxi_analyze_csv_file_path,CSV,OVERWRITE);

STD.File.DeSpray(Taxi.Files.taxi_analyze_file_path,
    '10.0.0.208',
    Taxi.Files.taxi_analysis_lz_file_path,
    -1,
    'http://play.hpccsystems.com:8010/FileSpray');