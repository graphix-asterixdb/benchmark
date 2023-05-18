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

MATCH    (person:Person)<-[:HAS_CREATOR]-(post:Post)<-[:REPLY_OF*0..]-(message:Message)
WHERE    $startDate < post.creationDate AND
         post.creationDate < $endDate AND
         $startDate < message.creationDate AND
         message.creationDate < $endDate
WITH     person,
         COUNT(DISTINCT post) AS threadCount,
         COUNT(DISTINCT message) AS messageCount
RETURN   person.id, 
         person.firstName, 
         person.lastName,
         threadCount,
         messageCount
ORDER BY messageCount DESC, 
         person.id ASC
LIMIT    $limit;
