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

MATCH          (person:Person)
OPTIONAL MATCH (person)<-[:HAS_CREATOR]-(message:Message)-[:REPLY_OF*0..]->(post:Post)
WHERE          message.content IS NOT NULL AND 
               message.length < $lengthThreshold AND
               message.creationDate > $startDate AND
               post.language IN $languages
WITH           person,
               COUNT(message) AS messageCount
RETURN         messageCount,
               COUNT(person) AS personCount
ORDER BY       personCount DESC,
               messageCount DESC;
