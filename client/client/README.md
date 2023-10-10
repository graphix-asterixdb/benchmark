<!--
 ! Licensed to the Apache Software Foundation (ASF) under one
 ! or more contributor license agreements.  See the NOTICE file
 ! distributed with this work for additional information
 ! regarding copyright ownership.  The ASF licenses this file
 ! to you under the Apache License, Version 2.0 (the
 ! "License"); you may not use this file except in compliance
 ! with the License.  You may obtain a copy of the License at
 !
 !   http://www.apache.org/licenses/LICENSE-2.0
 !
 ! Unless required by applicable law or agreed to in writing,
 ! software distributed under the License is distributed on an
 ! "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 ! KIND, either express or implied.  See the License for the
 ! specific language governing permissions and limitations
 ! under the License.
 !-->
# LDBC Social Network Benchmark Runner

This directory holds all scripts required to execute the _individual queries_ in the [LDBC Social Network Benchmark](https://arxiv.org/pdf/2001.02299.pdf).

## Runner Dependencies
We assume the following dependencies:
1. All queries, separated into individual files (see the sibling `resources` folder).
2. LDBC SNB data, generated using the following `run` command:
    ```bash
    git clone https://github.com/ldbc/ldbc_snb_datagen_spark.git
    
    ...
    
    ./tools/run.py \
      --parallelism ${PARALLELISM} \
      --memory {MEMORY} \
      -- \
      --format csv \
      --scale-factor ${SF} \
      --explode-edges \
      --mode raw \
      --format-options header=false,quoteAll=true \
      --output-dir {OUTPUT_DIR} \
      --generate-factors
    ```
3. Graphix, Neo4J, and TigerGraph loaded & primed to run the benchmark queries.
4. LDBC SNB query parameters, generated from the `paramgen.sh` scripts in the following repositories:
    ```bash
    git clone https://github.com/ldbc/ldbc_snb_interactive_driver.git
    
    ...
    
    ./paramgen/scripts/paramgen.sh
    
    ...
    
    git clone https://github.com/ldbc/ldbc_snb_bi.git
    
    ...
    
    ./paramgen/scripts/paramgen.sh
    ```

## Runner Execution

1. To execute the 