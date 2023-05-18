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

MATCH          (tagClass:TagClass)<-[:HAS_TYPE]-(tag:Tag)
WHERE          tagClass.name = $tagClass
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(m1:Message)
WHERE          $date <= m1.creationDate AND
               m1.creationDate < $date
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(m2:Message)
WHERE          $date <= m2.creationDate AND
               m2.creationDate < $date
WITH           tag.name AS tagName,
               COUNT(DISTINCT m1) AS countWindow1,
               COUNT(DISTINCT m2) AS countWindow2
RETURN         tagName,
               countWindow1,
               countWindow2,
               ABS(countWindow1 - countWindow2) AS diff
ORDER BY       diff DESC,
               tagName ASC
LIMIT          $limit;
