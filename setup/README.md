# Data generation

To generate the data for AsterixDB, first create the CSV files with the datagen and then run `load.sql`. Alternatively, you can download sample [JSON files](https://drive.google.com/drive/folders/1YezuC611OD5BB_Ub1WMWbja3O8oOs0ov) and then run `sampledata.sql`. 

To generate the CSV files, I used the [Hadoop datagen](https://github.com/ldbc/ldbc_snb_datagen_hadoop). To generate files for AsterixDB, I used this `params.ini` file:

```
ldbc.snb.datagen.generator.scaleFactor:snb.interactive.0.1

ldbc.snb.datagen.serializer.dateFormatter:ldbc.snb.datagen.util.formatter.LongDateFormatter

ldbc.snb.datagen.serializer.dynamicActivitySerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.activity.CsvCompositeMergeForeignDynamicActivitySerializer
ldbc.snb.datagen.serializer.dynamicPersonSerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.person.CsvCompositeMergeForeignDynamicPersonSerializer
ldbc.snb.datagen.serializer.staticSerializer:ldbc.snb.datagen.serializer.snb.csv.staticserializer.CsvCompositeMergeForeignStaticSerializer
```
You can change the first line to make a larger dataset. Then run `load.sql` to load the data into Asterix.

To generate files for Neo4J, I used this `params.ini` file:

```
ldbc.snb.datagen.generator.scaleFactor:snb.interactive.0.1

ldbc.snb.datagen.serializer.dateFormatter:ldbc.snb.datagen.util.formatter.LongDateFormatter

ldbc.snb.datagen.serializer.dynamicActivitySerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.activity.CsvCompositeDynamicActivitySerializer
ldbc.snb.datagen.serializer.dynamicPersonSerializer:ldbc.snb.datagen.serializer.snb.csv.dynamicserializer.person.CsvCompositeDynamicPersonSerializer
ldbc.snb.datagen.serializer.staticSerializer:ldbc.snb.datagen.serializer.snb.csv.staticserializer.CsvCompositeStaticSerializer
```

Then to load the data into Neo4J, I used the scripts [here](https://github.com/ldbc/ldbc_snb_bi/tree/main/cypher). Set the following environment variables based on your data source and where you would like to store the processed CSVs:

```bash
export NEO4J_VANILLA_CSV_DIR=`pwd`/test-data/vanilla
export NEO4J_CONVERTED_CSV_DIR=`pwd`/test-data/converted
```

Then run `scripts/load-in-one-step.sh`. 

