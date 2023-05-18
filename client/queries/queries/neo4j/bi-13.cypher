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

MATCH          (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(zombie:Person)
WHERE          zombie.creationDate < $endDate AND
               country.name = $country
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)
WHERE          message.creationDate < $endDate
WITH           zombie,
               COUNT(message) AS messageCount,
               (12 * ($endDate.year - zombie.creationDate.year)) + ($endDate.month - zombie.creationDate.month) + 1 AS months
WHERE          messageCount / months < 1
WITH           COLLECT(zombie) AS zombies
UNWIND         zombies AS zombie
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerZombie:Person)
WHERE          likerZombie IN zombies AND
               likerZombie.creationDate < $endDate
WITH           zombie,
               COUNT(likerZombie) AS zombieLikeCount
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerPerson:Person)
WHERE          likerPerson.creationDate < $endDate
WITH           zombie,
               zombieLikeCount, 
               COUNT(likerPerson) AS totalLikeCount
RETURN         zombie.id, 
               zombieLikeCount,
               totalLikeCount,
               CASE totalLikeCount
               WHEN 0
               THEN 0.0
               ELSE zombieLikeCount / TOFLOAT(totalLikeCount)
               END AS zombieScore
ORDER BY       zombieScore DESC,
               zombie.id ASC
LIMIT          $limit;
