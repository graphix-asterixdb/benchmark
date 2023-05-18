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

UNWIND   [ {letter: 'A', tag: $tagA, date: $dateA},
           {letter: 'B', tag: $tagB, date: $dateB} ] AS param
WITH     param.letter AS paramLetter,
         param.tag AS paramTagX,
         param.date AS paramDateX
CALL     {
              WITH           paramTagX,
                             paramDateX
              MATCH          (person1:Person)<-[:HAS_CREATOR]-(message1:Message)-[:HAS_TAG]->(tag:Tag {name: paramTagX})
              WHERE          message1.creationDate.day = paramDateX.day
                             // filter out Persons with more than $maxKnowsLimit friends who created the same kind of Message
              OPTIONAL MATCH (person1)-[:KNOWS]-(person2:Person)<-[:HAS_CREATOR]-(message2:Message)-[:HAS_TAG]->(tag)
              WHERE          message2.creationDate.day = paramDateX.day
              WITH           person1,
                             COUNT(DISTINCT message1) AS cm,
                             COUNT(DISTINCT person2) AS cp2
              WHERE          cp2 <= $maxKnowsLimit
              RETURN         person1,
                             cm
         }
WITH     person1,
         COLLECT({letter: paramLetter, messageCount: cm}) AS results
WHERE    SIZE(results) = 2
RETURN   person1.id,
         [r IN results WHERE r.letter = 'A' | r.messageCount][0] AS messageCountA,
         [r IN results WHERE r.letter = 'B' | r.messageCount][0] AS messageCountB
ORDER BY messageCountA + messageCountB DESC,
         person1.id ASC
LIMIT    $limit;
