IMPORT STD;
IMPORT Taxi;

Taxi.Files.taxi_clean_layout clean(Taxi.Files.taxi_raw_layout raw) := TRANSFORM
    SELF.vendor_id := (INTEGER)raw.vendor_id;
    SELF.pickup_date  := Std.Date.FromStringToDate(raw.tpep_pickup_datetime[..10], '%Y-%m-%d');
    SELF.pickup_time := Std.Date.FromStringToTime(raw.tpep_pickup_datetime[12..], '%H:%M:%S');
    SELF.dropoff_date  := Std.Date.FromStringToDate(raw.tpep_dropoff_datetime[..10], '%Y-%m-%d');
    SELF.dropoff_time := Std.Date.FromStringToTime(raw.tpep_dropoff_datetime[12..], '%H:%M:%S');
    passenger_count := (UNSIGNED1)raw.passenger_count;
    SELF.passenger_count := IF(passenger_count <= 0, 1, passenger_count);
    SELF.trip_distance := (DECIMAL10_2)raw.trip_distance;
    SELF.pickup_longitude := (DECIMAL9_6)raw.pickup_longitude;
    SELF.pickup_latitude := (DECIMAL9_6)raw.pickup_latitude;
    SELF.rate_code_id := (UNSIGNED1)raw.rate_code_id;
    SELF.store_and_fwd_flag := (STRING1)raw.store_and_fwd_flag;
    SELF.dropoff_longitude := (DECIMAL9_6)raw.dropoff_longitude;
    SELF.dropoff_latitude := (DECIMAL9_6)raw.dropoff_latitude;
    SELF.payment_type := (UNSIGNED1)raw.payment_type;
    SELF.fare_amount := (DECIMAL8_2)raw.fare_amount;
    SELF.extra:= (DECIMAL8_2)raw.extra;
    SELF.mta_tax := (DECIMAL8_2)raw.mta_tax;
    SELF.tip_amount := (DECIMAL8_2)raw.tip_amount;
    SELF.tolls_amount := (DECIMAL8_2)raw.tolls_amount;
    SELF.improvement_surcharge := (DECIMAL8_2)raw.improvement_surcharge;
    SELF.total_amount := (DECIMAL8_2)raw.total_amount;
END;

cleaned := PROJECT(Taxi.Files.taxi_raw_ds, clean(LEFT));  

OUTPUT(cleaned,,Taxi.Files.taxi_clean_file_path, THOR, COMPRESSED, OVERWRITE);