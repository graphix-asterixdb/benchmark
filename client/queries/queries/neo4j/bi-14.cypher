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

MATCH          (country1:Country {name: $country1})<-[:IS_PART_OF]-(city1:City)<-[:IS_LOCATED_IN]-(person1:Person),
               (country2:Country {name: $country2})<-[:IS_PART_OF]-(city2:City)<-[:IS_LOCATED_IN]-(person2:Person),
               (person1)-[:KNOWS]-(person2)
WITH           person1,
               person2,
               city1,
               0 AS score
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(c:Comment)-[:REPLY_OF]->(:Message)-[:HAS_CREATOR]->(person2)
WITH           DISTINCT person1,
                        person2,
                        city1,
                        score + ( CASE c
                                  WHEN NULL
                                  THEN 0
                                  ELSE 4
                                  END ) AS score
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(m:Message)<-[:REPLY_OF]-(:Comment)-[:HAS_CREATOR]->(person2)
WITH           DISTINCT person1,
                        person2,
                        city1,
                        score + ( CASE m
                                  WHEN NULL
                                  THEN 0
                                  ELSE 1
                                  END ) AS score
OPTIONAL MATCH (person1)-[:LIKES]->(m:Message)-[:HAS_CREATOR]->(person2)
WITH           DISTINCT person1,
                        person2,
                        city1,
                        score + ( CASE m
                                  WHEN NULL
                                  THEN 0
                                  ELSE 10
                                  END ) AS score
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(m:Message)<-[:LIKES]-(person2)
WITH           DISTINCT person1,
                        person2,
                        city1,
                        score + ( CASE m
                                  WHEN NULL
                                  THEN 0
                                  ELSE 1
                                  END ) AS score
ORDER BY       city1.name ASC,
               score DESC,
               person1.id ASC,
               person2.id ASC
WITH           city1,
               COLLECT({score: score, person1Id: person1.id, person2Id: person2.id})[0] AS top
RETURN         top.person1Id,
               top.person2Id,
               city1.name,
               top.score
ORDER BY       top.score DESC,
               top.person1Id ASC,
               top.person2Id ASC;
