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

MATCH    (startPerson:Person {id: $personId})
CALL     apoc.path.subgraphNodes(startPerson, {
	         relationshipFilter: "KNOWS",
             minLevel: 1,
             maxLevel: $minPathDistance-1
         })
YIELD    node
WITH     startPerson,
         COLLECT(DISTINCT node) AS nodesCloserThanMinPathDistance
CALL     apoc.path.subgraphNodes(startPerson, {
             relationshipFilter: "KNOWS",
             minLevel: 1,
             maxLevel: $maxPathDistance
         })
YIELD    node
WITH     nodesCloserThanMinPathDistance,
         COLLECT(DISTINCT node) AS nodesCloserThanMaxPathDistance
WITH     [n IN nodesCloserThanMaxPathDistance WHERE NOT n IN nodesCloserThanMinPathDistance] AS expertCandidatePersons
UNWIND   expertCandidatePersons AS expertCandidatePerson
MATCH    (expertCandidatePerson)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(:Country {name: $country}),
         (expertCandidatePerson)<-[:HAS_CREATOR]-(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->
         (:TagClass {name: $tagClass})
MATCH    (message)-[:HAS_TAG]->(tag:Tag)
RETURN   expertCandidatePerson.id,
         tag.name,
         COUNT(DISTINCT message) AS messageCount
ORDER BY messageCount DESC,
         tag.name ASC,
         expertCandidatePerson.id ASC
LIMIT    $limit;
