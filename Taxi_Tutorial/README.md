# Summary

Building an ECL application involves 6 steps:

1. Defining the ECL application project structure
2. Understanding the cluster setup
3. Importing the data into Thor
4. Clean the raw data and convert it to a standard form
5. Enrich the data
6. Performing analysis and creating an attribute file
7. Create a training dataset for training Generalized Linear Model to predict future trips
8. Build the GLM model

To understand these steps, let us consider a concrete example. We will start with Todd Schneider's excellent project at https://github.com/toddwschneider/nyc-taxi-data. The data contains 1.3 billion taxi and Uber trips originating in New York City. 

The first step in building an ECL application is to build a simplistic approach to quickly consume the data and to complete the first two steps above. To accomplish this, it is best to consider a smaller subset of the Taxi dataset. It will make it easier and faster to accomplish the tasks.

# 1. Defining the ECL application project structure

We will VS Code with the ECL plugin as our IDE for this project.

1. Create a folder called ECL_Tutorial. Open the folder in the VS Code editor. This will act as the projects working directory.
2. Create another folder called Taxi under ECL_Tutorial
3. Create the following files under Taxi:

**Files.ecl**

Contains all the layout definitions for all the files used in the project. 

**01_Data_Import_Job.ecl**

Contains the code to import data from the landing zone into Thor

**02_Data_Import_Validate_Job.ecl**

Contains the code to validate a data import

**03_Clean_Job.ecl**

Job that cleans and converts raw data to a cleaned version

**04_Enrich_Job.ecl**

Adds additional attributes to the cleaned data to make the dataset more valuable to the analysis process

**05_Analyze_Job.ecl**

Perform analysis on the enriched data. trip volumes etc. Also build an attribute dataset that can be used for creating a training dataset to create a machine learning GLM (General Linear Model) to predict trip volumes provided a date in the future. A very simple use case to get you started on using ML techniques within HPCC Systems.

**06_Train_Data_Job.ecl**

Create the training data set containing the pickup_year, pickup_month, pickup_day_of_week and count of trips

**07_GLM_Model_Job.ecl**

Builds the Generalized Linear Model by using the training data of pickup_year, pickup_month, pickup_day_of_week and count of trips

**Data_Export_Job.ecl**

Contains the code to export the data from Thor into the landing zone




Edit the Files.ecl to add:

```ecl
IMPORT STD;

EXPORT Files := MODULE
        EXPORT file_scope := '{Your Scope Prefix};

        /*
            Location of raw file on the landing zone
        */

        EXPORT taxi_lz_file_path := '/var/lib/HPCCSystems/mydropzone/yellow_tripdata_2015.csv';

        /*
            Raw file layout and dataset after it is imported into Thor
        */

        EXPORT taxi_raw_file_path := file_scope + '::taxi::in::yellow_tripdata_2015.csv';
 END;       

```

NOTE: Substitute {Your Scope Prefix} with a prefix like "~achala_training". If you do not do this, you might override somebody else's files.

# 2. Understanding the cluster setup

One AWS Instance running Thor, ROXIE, Middleware Services and the Landing Zone. The instance IP address is 10.0.0.208 in the case of our example. For Thor, we have setup four slave processes. ROXIE is setup as a single process.


# 3. Importing the data into Thor

A 100,000 record CSV data (sampled randomly across a 1.6 billion recordset) is available on the HPCC Systems playground [[landing zone |http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget]]

HPCC System services are based on a micro services architecture. For importing a file the **FileSpray** service is used. Since the file **yellow_tripdata_2015.csv** is available on the landing zone server and is mapped to the directory /var/lib/HPCCSystems/mydropzone. To import the data, we can write an ECL program with the following action:

Edit the Data_Import_Job.ecl and add the following code:

```ecl
IMPORT STD;
IMPORT Taxi;

STD.File.SprayVariable('{Your Landing Zone IP}',
       Taxi.Files.Landing_Zone.taxi_file_path,
       ,,,,
       'mythor',
       Taxi.Files.Raw.taxi_file_path,
       -1,
       'http://play.hpccsystems.com:8010/FileSpray',,TRUE);

```

NOTE: Substitute {Your Landing Zone IP} with your landing zones IP.

Execute the code using the VS Code debugger and view the results in the ECL Watch output

We could import the file using an user interface, but we want to demonstrate the power of the HPCC Systems micro services. You can invoke these services from any programming language by calling the services end point. In our example, we demonstrate an ECL program invoking the service.

If the program executes correctly, you will see a complete status. Alternatively, if there was an error, you will see an error message.

You can also verify that the file has been correctly sprayed by querying the logical file attributes:

Edit the **Data_Import_Validate_Job.ecl** and add the following code:

```ecl
IMPORT STD;
IMPORT Taxi;

file := Taxi.Files.taxi_raw_file_path;

OUTPUT(STD.File.GetLogicalFileAttribute(file,'recordSize'),NAMED('Record_Size'));
OUTPUT(STD.File.GetLogicalFileAttribute(file,'recordCount'),NAMED('Record_Count'));
OUTPUT(STD.File.GetLogicalFileAttribute(file,'size'),NAMED('File_Size'));
OUTPUT(STD.File.GetLogicalFileAttribute(file,'clusterName'),NAMED('Cluster_Name'));
OUTPUT(STD.File.GetLogicalFileAttribute(file,'directory'),NAMED('Directory'));
OUTPUT(STD.File.GetLogicalFileAttribute(file,'numparts'),NAMED('Data_Parts'));
```

Execute the code using the VS Code debugger and view the results in the ECL Watch output

One of the key features of ECL and HPCC Systems, is the concept of dynamic schema binding. That is, a runtime binding of an ECL Dataset to a layout that matches the format of the file. Let us modify the **Files.ecl** to demonstrate this capability.

Add the layout for the raw input file and then bind it to a dataset. When the taxi_raw_ds is read at runtime, the defined schema (taxi_raw_layout) is bound to it. This is the schema on read characteristic. 

```ecl
    EXPORT taxi_raw_layout := RECORD
        STRING  vendor_id;
        STRING  tpep_pickup_datetime;
        STRING  tpep_dropoff_datetime;
        STRING  passenger_count;
        STRING  trip_distance;
        STRING  pickup_longitude;
        STRING  pickup_latitude;
        STRING  rate_code_id;
        STRING  store_and_fwd_flag;
        STRING  dropoff_longitude;
        STRING  dropoff_latitude;
        STRING  payment_type;
        STRING  fare_amount;
        STRING  extra;
        STRING  mta_tax;
        STRING  tip_amount;
        STRING  tolls_amount;
        STRING  improvement_surcharge;
        STRING  total_amount;
    END;

    EXPORT taxi_raw_ds := DATASET(taxi_raw_file_path, taxi_raw_layout, CSV(HEADING(1)));
    
```

Now, modify the **Data_Import_Validate_Job.ecl** to add an OUTPUT step to visually validate the progress using ECL Watch

```ecl
IMPORT STD;
IMPORT Taxi;

file := Taxi.Files.taxi_raw_file_path;

.......
.......

OUTPUT(Taxi.Files.taxi_raw_ds,,NAMED('Raw_Taxi_Data'));
```


# 4. Clean the raw data and convert it to a standard form

So far, we have imported a file into Thor, read it as a Dataset and performed some basic validation. The next step is to clean and optimize the data. In this step, we will perform two operations:

1. Convert the STRING data types to an appropriate type
2. Fix data values that would not make sense

Edit the Files.ecl and add:

```ecl
         /*
            Cleaned file layout and dataset. The cleaned file is created after cleaning the 
            raw file.
        */
    
        EXPORT taxi_clean_file_path := file_scope + '::taxi::out::yellow_tripdata_2015_clean.thor';
        
        EXPORT taxi_clean_layout := RECORD
            UNSIGNED1   vendor_id;
            Std.Date.Date_t    pickup_date;
            Std.Date.Time_t    pickup_time;
            Std.Date.Date_t    dropoff_date;
            Std.Date.Time_t    dropoff_time;
            UNSIGNED1   passenger_count;
            DECIMAL10_2 trip_distance;
            DECIMAL9_6  pickup_longitude;
            DECIMAL9_6  pickup_latitude;
            UNSIGNED1   rate_code_id;
            STRING1     store_and_fwd_flag;
            DECIMAL9_6  dropoff_longitude;
            DECIMAL9_6  dropoff_latitude;
            UNSIGNED1   payment_type;
            DECIMAL8_2  fare_amount;
            DECIMAL8_2  extra;
            DECIMAL8_2  mta_tax;
            DECIMAL8_2  tip_amount;
            DECIMAL8_2  tolls_amount;
            DECIMAL8_2  improvement_surcharge;
            DECIMAL8_2  total_amount;
        END;

        EXPORT taxi_clean_ds := DATASET(taxi_clean_file_path, taxi_clean_layout, THOR);    

```

Edit the **Clean_Job.ecl** and add the following code

```ecl
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
```

We can do a lot more data cleaning but it is best to keep it simple for now. Execute the code and view the output in ECL Watch.




