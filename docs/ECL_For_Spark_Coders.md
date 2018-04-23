# An Introduction to ECL for Spark Programmers

How do we get them started quickly without having to learn ECL from scratch? Hence, the premise of this post is to introduce ECL to those already familiar with Spark. 

Specifically, we will be reviewing the RDD transformation functions supported by Spark like map(), filter() etc. Before we begin, please review the [ECL Introduction](ECL_Introduction.md) post that describes the Data Flow schematics of the ECL programming language. In addition, it should be remembered that ECL has more in common to SQL (declaritive) than to Python, Scala and Java (imperative). 

Before we begin, I want to touch upon one subtle difference between an RDD and an ECL DATASET:

*The number of RDD partitions can be created and manipulated in a Spark program. In ECL, the partitions are created based on the number of Slave processes or Slave process channels and hence cannot be manipulated in code* 


## RDD.map()     

A straight forward implementation of a map in ECL is the **PROJECT** function. PROJECT works on an ECL DATASET (equivalent of an RDD) by transforming each record. The output of a PROJECT is a new DATASET.

```ECL

IMPORT STD; 

raw_input_record := RECORD
    STRING text;
END;

raw_ds := DATASET([{'JOHN,SMITH,36'},
            {'RAJA,SUNDAR,25'},
            {'MARK,HANFLAND,50'}], raw_input_record);

person_record := RECORD
    STRING50 firstName;
    STRING50 lastName;
    INTEGER  age;
END;

person_ds := PROJECT(
    raw_ds,
    TRANSFORM(
        person_record,
        items := STD.STR.splitWords(LEFT.text, ',');
        SELF.firstName := items[1];
        SELF.lastName := items[2];
        SELF.age := (INTEGER)items[3];
    )
);

OUTPUT(person_ds);

```

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)


## RDD.filter() 

A filter can be applied directly on a DATASET as shown below

```ECL

person_record := RECORD
    STRING50 firstName;
    STRING50 lastName;
    INTEGER  age;
END;

person_ds := DATASET([{'JOHN','SMITH', 35}, 
                {'RAJA','SUNDAR', 31},
                {'MARK','HANFLAND', 25}], person_record);

filtered_ds := person_ds(age > 30);  

OUTPUT(filtered_ds);              

```

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)

## RDD.flatmap() 

A flatmap() transforms each element in an RDD to multiple elements. Use the **NORMALIZE** function in ECL to perform the equivalent operation. 

```ECL
IMPORT STD;

raw_input_record := RECORD
    INTEGER id;
    STRING text;
END;

raw_ds := DATASET ([{1, 'Coolest fans we have ever seen'},
                    {2, 'Share this with anybody'}]
              , raw_input_record);

word_record := RECORD
    INTEGER id;
    STRING100 word;
END;

word_record extractWord(raw_input_record l, UNSIGNED1 i) := TRANSFORM
  SELF.id := l.id;
  SELF.word := STD.Str.ToUpperCase(STD.Str.GetNthWord(l.text, i));
END;

norm_ds := NORMALIZE(raw_ds, 
              STD.Str.WordCount(LEFT.text), 
              extractWord(LEFT, COUNTER));

OUTPUT(norm_ds);
```
## RDD.GROUPBY and RDD.GROUPBYKEY

### Method 1 - Use the ECL GROUP and ROLLUP functions

```ECL
person_record := RECORD
    STRING name;
END; 

person_ds := DATASET([{'JOHN'}, 
                {'FRED'},
                {'ANNA'},
                {'JAMES'}], person_record);
                       
group_ds := GROUP(SORT(person_ds, name), name[1]);

grouped_record := RECORD
  STRING1 letter;
  DATASET(person_record) names;                     
  
END;
                       

grouped_record rollupRecords(person_record L, 
                          DATASET(person_record) R) := TRANSFORM
    SELF.letter := L.name[1];
    SELF.names := R;
END;
                      

rollup_ds := ROLLUP(group_ds, GROUP, rollupRecords(LEFT, ROWS(LEFT))); 

OUTPUT(rollup_ds);   
```

### Method 2 - Use the ECL GROUP and DENORMALIZE functions                     

```ECL
person_record := RECORD
    STRING name;
END; 

person_ds := DATASET([{'JOHN'}, 
                {'FRED'},
                {'ANNA'},
                {'JAMES'}], person_record);
                       
                       
grouped_record := RECORD
  STRING1 letter;
  DATASET(person_record) names;                     
  
END;
                       

grouped_record deNorm(person_record L, 
                      DATASET(person_record) R) := TRANSFORM
    SELF.letter := L.name[1];
    SELF.names := R;
END;

 
denorm_ds := DENORMALIZE(person_ds, person_ds, 
                         LEFT.name[1]=RIGHT.name[1], 
                         GROUP, deNorm(LEFT, ROWS(RIGHT)));
                         

OUTPUT(denorm_ds); 
```

## RDD.AggregateByKey and RDD.ReduceByKey

```ECL

employee_record := RECORD
    STRING50 firstName;
    STRING50 lastName;
    STRING50 department;
    REAL  salary;
END;

employee_ds := DATASET([{'JOHN','SMITH', 'SCIENCE', 100000}, 
                {'RAJA','SUNDAR', 'SCIENCE',150000},
                {'MARK','HANFLAND','MATH',120000}], employee_record);


dept_salary_record := RECORD
  employee_ds.department;
  REAL     totalSalary := SUM(GROUP, employee_ds.salary);    
END;

dept_slary_ds := TABLE(employee_ds, dept_salary_record, department);

OUTPUT(dept_slary_ds);

```
Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)


## RDD.MapPartitions

In Spark the MapPartitions executes the map operation on every partition independently. 

In ECL, replace the PROJECT function call in the RDD.Map example with the following code. The only difference is the addition of the 'LOCAL' keyword. The operation is ensured to work on every partition of the data independently. On a related note, all ECL transformation operations can be similarly executed on the partitions.

```ECL

person_ds := PROJECT(
    raw_ds,
    TRANSFORM(
        person_record,
        items := STD.STR.splitWords(LEFT.text, ',');
        SELF.firstName := items[1];
        SELF.lastName := items[2];
        SELF.age := (INTEGER)items[3];
    ),
    LOCAL
);

```

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)

## RDD.UNION

A RDD.UNION, combines two RDDs by creating a new RDD by simply appending the partitions. In ECL, you can combine data from two or more DATASETS using the '+' operator.

```ECL

person_record := RECORD
    STRING name;
END; 

person_ds1 := DATASET([{'JOHN'}, 
                  {'FRED'},
                  {'ANNA'},
                  {'JAMES'}], person_record);

person_ds2 := DATASET([{'JESSICA'}, 
                  {'MARK'},
                  {'TRISH'},
                  {'JAMES'}], person_record);                  

both_ds := person_ds1 + person_ds2;

OUTPUT(both_ds);

```  

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)

## RDD.JOIN


```ECL

person_record := RECORD
    INTEGER id;
    INTEGER address_id;
    STRING name;
END; 

address_record := RECORD
    INTEGER address_id;
    STRING address;
END;

person_ds := DATASET([{1,22,'JOHN'}, {2,33,'FRED'},
                      {3,22,'ANNA'}, {4,34,'JAMES'}], person_record);

address_ds := DATASET([{22, '210 Devon Mill Ct, Alpharetta, GA 30005'},
                       {33,'4945 Shelborne Dr, Cumming, GA 30095'}, 
                       {34,'Some Address, Cumming, GA 30096'}],
                       address_record);

person_addr_ds := JOIN(person_ds, address_ds, 
             LEFT.address_id=RIGHT.address_id);

OUTPUT(person_addr_ds);

```

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)


## RDD.DISTINCT

Use a combination of the ECL's SORT and DEDUP to accomplish the DISTINCT functionality

```ECL

person_record := RECORD
    STRING name;
END; 

person_ds := DATASET([{'JOHN'}, 
                  {'FRED'},
                  {'ANNA'},
                  {'JAMES'},
                  {'JOHN'},
                  {'ANNA'}], person_record);


distinct_ds := DEDUP(SORT(person_ds, name));

OUTPUT(distinct_ds);


```

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)

## RDD.PARTITIONBY

This is a powerful feature that rebalances the partitions by redistributing the data by a key. This helps in maximizing a parallel operation by ensuring that all the records that match a key will reside in exactly one partition. In ECL, use the DISTRIBUTE function to rebalance the existing partitions. However, it should be noted that you cannot add or subtract partitions in ECL. 

```ECL

person_record := RECORD
    STRING100 name;
    STRING2 state_code;
END; 

person_ds := DATASET([{'JOHN', 'GA'}, 
                  {'FRED', 'CA'},
                  {'ANNA', 'CA'},
                  {'JAMES', 'FL'},
                  {'JESSICA', 'AL'},
                  {'TRISH', 'GA'}], person_record);


distributed_ds := DISTRIBUTE(person_ds, HASH32(state_code));

//Perform some operations on the new partitions

OUTPUT(distributed_ds,, '~examples::out::person');


```

Try out the code in the [ECL Playground](http://play.hpccsystems.com:8010/?Widget=ECLPlaygroundWidget)


As you can see, ECL has a lot in common to Spark. That said, the post also highlights why ECL is a natural language for ETL processing. With its strong data typing semantics and abstractions for parallel processing, ECL's goal is to enable developers to concentrate on solving data problems. 

P.S. I cannot claim to be an expert on Spark. Examples in this post have been derived after referring to the [Databricks training manual](https://training.databricks.com/visualapi.pdf). 