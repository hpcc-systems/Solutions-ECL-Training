@title[Introduction]

### NYC Taxi Trip Analysis 

#### Lear HPCC Systems Data Lake technology and ECL

#### Learn ECL while analyzing a 1.3 billion record dataset


---

@title[Summary]

### Development Flow

<ol>
<li class="fragment" data-fragment-index="1">Defining the ECL application project structure</li>
<li class="fragment" data-fragment-index="2">Importing the data into Thor</li>
<li class="fragment" data-fragment-index="3">Cleaning the raw data</li>
<li class="fragment" data-fragment-index="4">Enriching the cleaned data</li>
<li class="fragment" data-fragment-index="5">Creating an attribute file</li>
<li class="fragment" data-fragment-index="6">Creating a training dataset to predict trip volume on a certain day</li>
<li class="fragment" data-fragment-index="7">Build a Generalized Linear Model</li>
</ol>

---

@title[Defining the ECL application project structure]

We will VS Code with the ECL plugin as our IDE for this project.

1. Create a folder called Taxi_Tutorial. Open the folder in the VS Code editor. This will act as the projects working directory.
2. Create another folder called Taxi under Taxi_Tutorial
3. Create the following files under Taxi:

----