IMPORT STD;
IMPORT Taxi;

Taxi.Files.taxi_enrich_layout enrich(Taxi.Files.taxi_clean_layout clean,
     UNSIGNED4 c) := TRANSFORM
    SELF := clean;
    SELF.record_id := c; 
    SELF.pickup_minutes_after_midnight 
         := Std.Date.Hour(SELF.pickup_time) * 60 + Std.Date.Minute(SELF.pickup_time);
    SELF.dropoff_minutes_after_midnight 
         := Std.Date.Hour(SELF.dropoff_time) * 60 + Std.Date.Minute(SELF.dropoff_time);
    SELF.pickup_time_hour := Std.Date.Hour(SELF.pickup_time);
    SELF.dropoff_time_hour := Std.Date.Hour(SELF.dropoff_time);
    SELF.pickup_day_of_week := Std.Date.DayOfWeek(SELF.pickup_date);
    SELF.dropoff_day_of_week := Std.Date.DayOfWeek(SELF.dropoff_date);
    SELF.pickup_month_of_year := Std.Date.Month(SELF.pickup_date);
    SELF.dropoff_month_of_year := Std.Date.Month(SELF.dropoff_date);
    SELF.pickup_year := Std.Date.Year(SELF.pickup_date);
    SELF.dropoff_year := Std.Date.Year(SELF.dropoff_date); 
    SELF.pickup_day_of_month := Std.Date.Day(SELF.pickup_date); 
    SELF.dropoff_day_of_month := Std.Date.Day(SELF.dropoff_date);
END; 

enriched := PROJECT(Taxi.Files.taxi_clean_ds, enrich(LEFT, COUNTER));

OUTPUT(enriched,,Taxi.Files.taxi_enrich_file_path, THOR, COMPRESSED, OVERWRITE);