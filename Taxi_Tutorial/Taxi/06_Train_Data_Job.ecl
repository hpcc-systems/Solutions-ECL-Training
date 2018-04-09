IMPORT STD;
IMPORT Taxi;

Taxi.Files.taxi_train_layout train(Taxi.Files.taxi_analyze_layout analyzed) := TRANSFORM
    SELF.pickup_year := Std.Date.Year(analyzed.pickup_date);
    SELF.pickup_month := Std.Date.Month(analyzed.pickup_date);
    SELF.pickup_day_of_week := Std.Date.DayOfWeek(analyzed.pickup_date);

    SELF := analyzed;
END;  

trained := PROJECT(Taxi.Files.taxi_analyze_ds, train(LEFT)); 

OUTPUT(trained,,Taxi.Files.taxi_train_file_path, THOR, COMPRESSED, OVERWRITE);