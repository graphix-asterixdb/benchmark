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

MATCH    (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(post:Post)-[:HAS_TAG]->(tag:Tag),
         (person)-[:KNOWS]-(:Person)<-[:HAS_CREATOR]-(post2:Post)
WHERE    person.id = $personId AND
         $startDate <= post.creationDate AND
         post.creationDate < $startDate + DURATION("P" + $durationDays + "D") AND
         post2.creationDate < $startDate AND
         NOT EXISTS((post2)-[:HAS_TAG]->(tag))
WITH     tag,
         COUNT(DISTINCT post) AS postCount
RETURN   tag.name,
         postCount
ORDER BY postCount DESC,
         tag.name ASC
LIMIT    $limit;
