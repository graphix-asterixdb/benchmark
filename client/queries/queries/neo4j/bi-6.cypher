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

MATCH          (tag:Tag)<-[:HAS_TAG]-(message1:Message)-[:HAS_CREATOR]->(person1:Person)
WHERE          tag.name = $tag
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:Person)<-[:HAS_CREATOR]-(message2:Message)
OPTIONAL MATCH (message2)<-[:LIKES]-(person3:Person)
WITH           person1,
               person2,
               COUNT(person3) AS popularityScore
WITH           person1,
               SUM(popularityScore) AS authorityScore
RETURN         person1.id,
               authorityScore
ORDER BY       authorityScore DESC,
               person1.id ASC
LIMIT          $limit;
