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

MATCH          (person:Person)-[:KNOWS*2..2]-(foaf:Person)-[:IS_LOCATED_IN]->(city:City)
WHERE          person.id = $personId AND
               NOT EXISTS((person)-[:KNOWS]-(foaf)) AND
               NOT foaf=person
WITH           person,
               foaf,
               city, 
               DATETIME({epochmillis: foaf.birthday}) AS bd
WHERE          ( (bd.month = $month AND bd.day >= 21) OR
                 (bd.month = ($month % 12) + 1 AND bd.day < 22) )
OPTIONAL MATCH (person)-[:HAS_INTEREST]->(tag:Tag)<-[:HAS_TAG]-(post:Post)-[:HAS_CREATOR]->(foaf)
WITH           person,
               foaf,
               city,
               COUNT(DISTINCT post) as common
OPTIONAL MATCH (post:Post)-[:HAS_CREATOR]->(foaf)
WHERE          NOT EXISTS((person)-[:HAS_INTEREST]->(:Tag)<-[:HAS_TAG]-(post))
WITH           person,
               foaf,
               city,
               common,
               COUNT(DISTINCT post) as uncommon
RETURN         foaf.id,
               foaf.firstName,
               foaf.lastName,
               common - uncommon as commonInterestScore,
               foaf.gender,
               city.name
ORDER BY       commonInterestScore DESC,
               foaf.id ASC
LIMIT          $limit;
