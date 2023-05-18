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

MATCH    (person1:Person)<-[:HAS_CREATOR]-(message1:Message)-[:REPLY_OF*0..]->(post1:Post)<-[:CONTAINER_OF]-(forum1:Forum),
         (message1)-[:HAS_TAG]->(tag:Tag),
         (forum1)-[:HAS_MEMBER]->(person2:Person)<-[:HAS_CREATOR]-(comment:Comment)-[:HAS_TAG]->(tag),
         (forum1)-[:HAS_MEMBER]->(person3:Person)<-[:HAS_CREATOR]-(message2:Message),
         (comment)-[:REPLY_OF]->(message2)-[:REPLY_OF*0..]->(post2:Post)<-[:CONTAINER_OF]-(forum2:Forum)
MATCH    (comment)-[:HAS_TAG]->(tag)
MATCH    (message2)-[:HAS_TAG]->(tag)
WHERE    forum1 <> forum2 AND
         tag.name = $tag AND
         message2.creationDate > message1.creationDate + DURATION("P" + $delta + "H") AND
         NOT EXISTS((forum2)-[:HAS_MEMBER]->(person1))
RETURN   person1.id, 
         COUNT(DISTINCT message2) AS messageCount
ORDER BY messageCount DESC,
         person1.id ASC
LIMIT    $limit 
