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

MATCH  (person1:Person {id: $person1Id}), (person2:Person {id: $person2Id})
CALL   gds.shortestPath.dijkstra.stream({
       nodeQuery: 'MATCH  (p:Person)
                   RETURN ID(p) AS id',
       relationshipQuery: '
         MATCH          (pA:Person)-[knows:KNOWS]-(pB:Person)

         // case 1: every reply (by one of the Persons) to a Post (by the other Person) is worth 1.0 point
         OPTIONAL MATCH (pA)<-[:HAS_CREATOR]-(c:Comment)-[:REPLY_OF]->(post:Post)-[:HAS_CREATOR]->(pB),
                        (post)<-[:CONTAINER_OF]-(forum:Forum)
         WHERE          forum.creationDate >= $startDate AND
                        forum.creationDate <= $endDate
         WITH           knows,
                        pA,
                        pB, 
                        COUNT(c) * 1.0 AS w1

         // case 2: every reply (by ones of the Persons) to a Comment (by the other Person) is worth 0.5 points
         OPTIONAL MATCH (pA)<-[:HAS_CREATOR]-(c1:Comment)-[:REPLY_OF]->(c2:Comment)-[:HAS_CREATOR]->(pB),
                        (c2)-[:REPLY_OF*]->(:Post)<-[:CONTAINER_OF]-(forum:Forum)
         WHERE          forum.creationDate >= $startDate AND
                        forum.creationDate <= $endDate
         WITH           knows,
                        pA,
                        pB,
                        w1 + COUNT(c1) * 0.5 AS w2

         // case 1 reverse
         OPTIONAL MATCH (pA)<-[:HAS_CREATOR]-(post:Post)<-[:REPLY_OF]-(c:Comment)-[:HAS_CREATOR]->(pB),
                        (post)<-[:CONTAINER_OF]-(forum:Forum)
         WHERE          forum.creationDate >= $startDate AND
                        forum.creationDate <= $endDate
         WITH           knows,
                        pA,
                        pB,
                        w2 + COUNT(c) * 1.0 AS w3

         // case 2 reverse
         OPTIONAL MATCH (pA)<-[:HAS_CREATOR]-(c2:Comment)<-[:REPLY_OF]->(c1:Comment)-[:HAS_CREATOR]->(pB),
                        (c2)-[:REPLY_OF*]->(:Post)<-[:CONTAINER_OF]-(forum:Forum)
         WHERE          forum.creationDate >= $startDate AND
                        forum.creationDate <= $endDate
         WITH           knows,
                        pA,
                        pB,
                        w3 + COUNT(c1) * 0.5 AS w4

         RETURN         ID(pA) AS source,
                        ID(pB) AS target,
                        1 / (w4 + 1) AS weight
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
RETURN totalCost
