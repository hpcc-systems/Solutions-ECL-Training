IMPORT STD;
IMPORT Taxi;

STD.File.SprayDelimited('10.0.0.208',
       Taxi.Files.taxi_lz_file_path,
       ,,,, 
       'mythor',
       Taxi.Files.taxi_raw_file_path,
       -1,
       'http://play.hpccsystems.com:8010/FileSpray',,TRUE);