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

MATCH          (tag:Tag {name: $tag})
OPTIONAL MATCH (tag)<-[interest:HAS_INTEREST]-(person:Person)
WITH           tag,
               COLLECT(person) AS interestedPersons
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person:Person)
WHERE          $startDate < message.creationDate AND
               message.creationDate < $endDate
WITH           tag,
               interestedPersons,
               interestedPersons + COLLECT(person) AS persons
UNWIND         persons AS person
WITH           DISTINCT tag,
                        person
WITH           tag,
               person,
               100 * SIZE([(tag)<-[interest:HAS_INTEREST]-(person) | interest]) +
                     SIZE([(tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person)
                           WHERE $startDate < message.creationDate AND
                                 message.creationDate < $endDate | message]) AS score
OPTIONAL MATCH (person)-[:KNOWS]-(friend)
WITH           person,
               score,
               100 * SIZE([(tag)<-[interest:HAS_INTEREST]-(friend) | interest]) +
                     SIZE([(tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(friend)
                           WHERE $startDate < message.creationDate AND
                                 message.creationDate < $endDate | message]) AS friendScore
RETURN         person.id,
               score,
               SUM(friendScore) AS friendsScore
ORDER BY       score + friendsScore DESC,
               person.id ASC
LIMIT          $limit;
