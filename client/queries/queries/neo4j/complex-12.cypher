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

MATCH    (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(comment:Comment)-[:REPLY_OF]->(post:Post),
         (post)-[:HAS_TAG]->(tag:Tag)-[:HAS_TYPE]->(:TagClass)-[:IS_SUBCLASS_OF*0..]->(tagClass:TagClass)
WHERE    person.id = $personId AND
         tagClass.name = $tagClassName
WITH     friend,
         COLLECT(DISTINCT tag.name) AS tagNames,
         COUNT(DISTINCT comment) as replyCount
RETURN   friend.id,
         friend.firstName,
         friend.lastName,
         tagNames,
         replyCount    
ORDER BY replyCount DESC,
         friend.id ASC
LIMIT    $limit;
