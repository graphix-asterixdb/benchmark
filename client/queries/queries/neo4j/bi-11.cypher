// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

MATCH  (a:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country:Country),
       (b:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
       (c:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
       (a)-[k1:KNOWS]-(b)-[k2:KNOWS]-(c)-[k3:KNOWS]-(a)
WHERE  a.id < b.id AND
       b.id < c.id AND
       $startDate <= k1.creationDate AND
       k1.creationDate <= $endDate AND
       $startDate <= k2.creationDate AND
       k2.creationDate <= $endDate AND
       $startDate <= k3.creationDate AND
       k3.creationDate <= $endDate AND
       country.name = $country
WITH   DISTINCT a,b,c
RETURN COUNT(*) AS count;