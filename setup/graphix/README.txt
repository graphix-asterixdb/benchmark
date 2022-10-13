This directory contains all setup scripts to be run in Graphix.
1. The script `create-s1.sqlpp` reads CSVs straight from the LDBC generator into AsterixDB external datasets.
2. The script `create-s2.sqlpp` will transform the external datasets from `create-s1.sqlpp` into a document-model-based representation of the data (i.e. with object nesting and array nesting).
3. The script `create-s3.sqlpp` will create a graph view using the internal datasets from `create-s2.sqlpp`, to be used by the queries in `queries/graphix`.