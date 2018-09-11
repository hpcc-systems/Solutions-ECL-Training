IMPORT Taxi;
IMPORT Visualizer.Visualizer;

cnt_by_weekday_ds:= TABLE(Taxi.Files.taxi_enrich_ds, 
             {pickup_day_of_week, UNSIGNED4 cnt := COUNT(GROUP)}, 
             pickup_day_of_week);


cnt_by_weekday_alpha_ds := PROJECT(cnt_by_weekday_ds, TRANSFORM({STRING weekday, UNSIGNED4 cnt}, 
                                           SELF.weekday := CASE(LEFT.pickup_day_of_week, 1 => 'Sun', 2 => 'Mon', 3 => 'Tue', 4 => 'Wed', 5 => 'Thur', 6 => 'Fri', 'Sat'); 
                                           SELF.cnt := LEFT.cnt));

OUTPUT(cnt_by_weekday_alpha_ds, NAMED('count_by_weekday'));
Visualizer.TwoD.pie('count_by_week_day_pie',, 'count_by_weekday');
Visualizer.MultiD.Bar('count_by_week_day_bar',, 'count_by_weekday');