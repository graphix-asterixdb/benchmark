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

MATCH    (person:Person)-[:KNOWS*1..2]-(otherPerson:Person)
WHERE    person.id = $personId
MATCH    (otherPerson)<-[:HAS_CREATOR]-(m1:Message)-[:IS_LOCATED_IN]->(countryX:Country)
WHERE    $startDate <= m1.creationDate AND
         m1.creationDate < $startDate + DURATION("P" + $durationDays + "D") AND
         countryX.name = $countryXName
MATCH    (otherPerson)<-[:HAS_CREATOR]-(m2:Message)-[:IS_LOCATED_IN]->(countryY:Country)
WHERE    $startDate <= m2.creationDate AND
         m2.creationDate < $startDate + DURATION("P" + $durationDays + "D") AND
         countryY.name = $countryYName
MATCH    (otherPerson)-[:IS_LOCATED_IN]->(city:City)
WHERE    NOT EXISTS((city)-[:IS_PART_OF]->(countryX)) AND
         NOT EXISTS((city)-[:IS_PART_OF]->(countryY))
WITH     otherPerson,
         COUNT(DISTINCT m1) as xCount,
         COUNT(DISTINCT m2) as yCount
RETURN   otherPerson.id,
         otherPerson.firstName,
         otherPerson.lastName,
         xCount,
         yCount,
         xCount + yCount AS count
ORDER BY count DESC,
         otherPerson.id ASC
LIMIT    $limit;
