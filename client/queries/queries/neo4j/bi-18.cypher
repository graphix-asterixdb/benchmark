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

MATCH    (tag:Tag)<-[:HAS_INTEREST]-(person1:Person)-[:KNOWS]-(mutualFriend:Person)-[:KNOWS]-(person2:Person)-[:HAS_INTEREST]->(tag)
WHERE    tag.name = $tag AND
         person1 <> person2 AND
         NOT (person1)-[:KNOWS]-(person2)
RETURN   person1.id AS person1Id, 
         person2.id AS person2Id,
         COUNT(DISTINCT mutualFriend) AS mutualFriendCount
ORDER BY mutualFriendCount DESC,
         person1Id ASC,
         person2Id ASC
LIMIT    $limit;
