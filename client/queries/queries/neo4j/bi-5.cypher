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

MATCH          (tag:Tag)<-[:HAS_TAG]-(m:Message)-[:HAS_CREATOR]->(person:Person)
WHERE          tag.name = $tag
OPTIONAL MATCH (liker:Person)-[:LIKES]->(m)
OPTIONAL MATCH (comment:Comment)-[:REPLY_OF]->(m)
WITH           person,
               COUNT(DISTINCT m) AS messageCount,
               COUNT(DISTINCT liker) AS likeCount,
               COUNT(DISTINCT comment) AS replyCount
RETURN         person.id,
               replyCount,
               likeCount,
               messageCount,
               messageCount + 2 * replyCount + 10 * likeCount AS score
ORDER BY       score DESC,
               person.id ASC
LIMIT          $limit;
