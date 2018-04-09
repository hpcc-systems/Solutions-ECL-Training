@title[Introduction]

### Analyze 1.3 billion NYC Taxi Trip 

#### Learn HPCC Systems Data Lake technology and ECL

---

@title[Summary]

### Development Flow

<ol>
<li class="fragment" data-fragment-index="1">Defining the ECL application project structure</li>
<li class="fragment" data-fragment-index="2">Importing the data into Thor</li>
<li class="fragment" data-fragment-index="3">Cleaning the raw data</li>
<li class="fragment" data-fragment-index="4">Enriching the cleaned data</li>
<li class="fragment" data-fragment-index="5">Creating an attribute file</li>
<li class="fragment" data-fragment-index="6">Creating a training dataset</li>
<li class="fragment" data-fragment-index="7">Build a Generalized Linear Model</li>
</ol>

---

@title[Defining the ECL application project structure]

We will VS Code with the ECL plugin as our IDE for this project.

1. Create a folder called Taxi_Tutorial. 
2. Open the folder in the VS Code editor. 
3. Create another folder called Taxi under Taxi_Tutorial.
4. Create the following files under Taxi

---

@title[Project Files]

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
