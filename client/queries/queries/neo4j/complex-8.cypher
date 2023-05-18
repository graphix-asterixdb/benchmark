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

MATCH    (person:Person)<-[:HAS_CREATOR]-(message:Message)<-[:REPLY_OF]-(comment:Comment)-[:HAS_CREATOR]->(commentAuthor:Person)
WHERE    person.id = $personId
RETURN   commentAuthor.id,
         commentAuthor.firstName,
         commentAuthor.lastName,
         comment.creationDate.epochMillis,
         comment.id,
         comment.content
ORDER BY comment.creationDate DESC,
         comment.id ASC
LIMIT    $limit;
