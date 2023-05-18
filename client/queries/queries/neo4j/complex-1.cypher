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

MATCH          path = (person:Person)-[:KNOWS*1..3]-(otherPerson:Person)
WHERE          person.id = $personId AND
               otherPerson.firstName = $firstName AND
               person <> otherPerson
WITH           otherPerson,
               MIN(LENGTH(path)) AS distanceFromPerson
MATCH          (otherPerson)-[:IS_LOCATED_IN]->(locationCity:City)
OPTIONAL MATCH (otherPerson)-[w:WORK_AT]->(company:Company)-[:IS_LOCATED_IN]->(companyCountry:Country)
WITH           otherPerson,
               locationCity,
               distanceFromPerson,
               COLLECT([company.name, w.workFrom, companyCountry.name]) AS companies
OPTIONAL MATCH (otherPerson)-[s:STUDY_AT]->(university:University)-[:IS_LOCATED_IN]->(universityCity:City)
WITH           otherPerson,
               locationCity, 
               distanceFromPerson, 
               companies,
               COLLECT([university.name, s.classYear, universityCity.name]) AS universities
RETURN         otherPerson.id,
               otherPerson.lastName,
               distanceFromPerson,
               otherPerson.birthday,
               otherPerson.creationDate.epochMillis,
               otherPerson.gender,
               otherPerson.browserUsed,
               otherPerson.locationIP,
               otherPerson.email,
               otherPerson.speaks,
               locationCity.name,
               universities,
               companies
ORDER BY       distanceFromPerson ASC,
               otherPerson.lastName ASC, 
               otherPerson.id ASC
LIMIT          $limit;
