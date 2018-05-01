IMPORT Taxi;
IMPORT Visualizer;

cnt_by_weekday_ds:= TABLE(Taxi.Files.taxi_enrich_ds, 
             {pickup_day_of_week, UNSIGNED4 cnt := COUNT(GROUP)}, 
             pickup_day_of_week);


OUTPUT(cnt_by_weekday_ds, NAMED('count_by_weekday'));
Visualizer.TwoD.pie('count_by_week_day_pie',, 'count_by_weekday');
