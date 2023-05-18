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

MATCH (person1:Person {id: $person1Id}), (person2:Person {id: $person2Id})
CALL gds.shortestPath.dijkstra.stream({
  nodeQuery: 'MATCH (p:Person) RETURN id(p) AS id',
  relationshipQuery: '
    MATCH  (pA:Person)-[knows:KNOWS]-(pB:Person),
           (pA)<-[:HAS_CREATOR]-(m1:Message)-[r:REPLY_OF]-(m2:Message)-[:HAS_CREATOR]->(pB)
    WITH   ID(pA) AS source,
           ID(pB) AS target,
           COUNT(r) AS numInteractions
    RETURN source,
           target,
           CASE WHEN FLOOR(40-SQRT(numInteractions)) > 1
                THEN FLOOR(40-SQRT(numInteractions))
                ELSE 1 END AS weight
    ',
  sourceNode: person1,
  targetNode: person2,
  relationshipWeightProperty: 'weight'
})
YIELD  index,
       sourceNode,
       targetNode,
       totalCost,
       nodeIds,
       costs,
       path
RETURN [person IN NODES(path) | person.id] AS personIdsInPath,
       totalCost AS pathWeight
LIMIT  1
