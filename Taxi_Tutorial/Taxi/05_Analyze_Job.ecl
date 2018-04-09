IMPORT STD;
IMPORT Taxi;

//count of pickups by a weekday

cnt_by_weekday_ds:= TABLE(Taxi.Files.taxi_enrich_ds, 
             {pickup_day_of_week, UNSIGNED4 cnt := COUNT(GROUP)}, 
             pickup_day_of_week);

OUTPUT(cnt_by_weekday_ds,,NAMED('count_by_weekday'));

//***************Try some of this********************

//What is the avg volume of trips between 7 AM to 10 AM for each week day?

//What hours of the day do you see the maximimum trips?

//Daily trips grouped by hour

//***************************************************

//count of pickups daily
cnt_per_day_ds := TABLE(Taxi.Files.taxi_enrich_ds, 
            {pickup_date, UNSIGNED4 cnt := COUNT(GROUP)}, 
            pickup_date);


OUTPUT(cnt_per_day_ds,,Taxi.Files.taxi_analyze_file_path, 
      THOR, COMPRESSED, OVERWRITE);





