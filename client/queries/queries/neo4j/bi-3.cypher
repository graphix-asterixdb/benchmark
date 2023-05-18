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

MATCH    (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(person:Person)<-[:HAS_MODERATOR]-(forum:Forum),
         (forum)-[:CONTAINER_OF]->(:Post)<-[:REPLY_OF*0..]-(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagClass:TagClass)
WHERE    country.name = $country AND
         tagClass.name = $tagClass
WITH     forum,
         person,
         COUNT(DISTINCT message) AS messageCount
RETURN   forum.id,
         forum.title,
         forum.creationDate.epochMillis,
         person.id, 
         messageCount
ORDER BY messageCount DESC,
         forum.id ASC
LIMIT    $limit;
