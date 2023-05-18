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

MATCH          (country:Country)<-[:IS_PART_OF]-(city:City)<-[:IS_LOCATED_IN]-(member:Person)<-[:HAS_MEMBER]-(forum:Forum)
WHERE          forum.creationDate > $date
WITH           forum,
               country,
               COUNT(member) AS memberCount
WITH           forum,
               MAX(memberCount) AS memberCount
ORDER BY       memberCount DESC
LIMIT          100
WITH           COLLECT(forum) AS topForums
MATCH          (forum1:Forum), (person:Person)<-[:HAS_MEMBER]-(forum2:Forum)
WHERE          forum1 IN topForums AND
               forum2 IN topForums
OPTIONAL MATCH (forum1)-[:CONTAINER_OF]->(:Post)<-[:REPLY_OF*0..]-(message:Message)-[:HAS_CREATOR]->(person)
WITH           person,
               COUNT(DISTINCT message) AS messageCount
RETURN         person.id,
               person.firstName,
               person.lastName,
               person.creationDate.epochMillis,
               messageCount
ORDER BY       messageCount DESC,
               person.id ASC
LIMIT          $limit;
