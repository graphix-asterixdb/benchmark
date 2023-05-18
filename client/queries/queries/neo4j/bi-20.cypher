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

MATCH    (company:Company {name: $company})<-[:WORK_AT]-(person1:Person),
         (person2:Person {id: $person2Id})
CALL     gds.shortestPath.dijkstra.stream({
           nodeQuery: 'MATCH  (p:Person)
                       RETURN id(p) AS id',
           relationshipQuery:
             'MATCH  (personA:Person)-[:KNOWS]-(personB:Person),
                     (personA)-[saA:STUDY_AT]->(u:University)<-[saB:STUDY_AT]-(personB)
              RETURN ID(personA) AS source,
                     ID(personB) AS target,
                     MIN(abs(saA.classYear - saB.classYear)) + 1 AS weight',
           sourceNode: person1,
           targetNode: person2,
           relationshipWeightProperty: 'weight'
         })
YIELD    totalCost
WHERE    person1.id <> $person2Id
RETURN   person1.id,
         totalCost AS totalWeight
ORDER BY totalWeight ASC,
         person1.id ASC
LIMIT    $limit;
