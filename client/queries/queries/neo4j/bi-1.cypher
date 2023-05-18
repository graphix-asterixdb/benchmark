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

MATCH    (message:Message)
WHERE    message.creationDate < $datetime
WITH     COUNT(message) AS totalMessageCountInt
WITH     toFloat(totalMessageCountInt) AS totalMessageCount
MATCH    (message:Message)
WHERE    message.creationDate < $datetime AND
         message.content IS NOT NULL
WITH     totalMessageCount,
         message,
         message.creationDate.year AS year
WITH     totalMessageCount,
         year,
         message:Comment AS isComment,
         CASE WHEN message.length < 40
              THEN 0
              WHEN message.length < 80
              THEN 1
              WHEN message.length < 160
              THEN 2
              ELSE 3 END AS lengthCategory,
         COUNT(message) AS messageCount,
         SUM(message.length) / TOFLOAT(COUNT(message)) AS averageMessageLength,
         SUM(message.length) AS sumMessageLength
RETURN   year,
         isComment,
         lengthCategory,
         messageCount,
         averageMessageLength,
         sumMessageLength,
         messageCount / totalMessageCount AS percentageOfMessages
ORDER BY year DESC,
         isComment ASC,
         lengthCategory ASC;