WITH T AS (
FROM   GRAPH snb.snbGraph
MATCH  (person:Person)<-[:HAS_CREATOR]-(post:Message)<-[:REPLY_OF{1,5}]-(message:Message)
WHERE  1313579421570 < post.creationDate AND post.creationDate < 1342803345373
  AND  1313579421570 < message.creationDate AND message.creationDate < 1342803345373
  AND  post.isPost = true
SELECT person, post, message

UNION ALL

FROM   GRAPH snb.snbGraph
MATCH  (person:Person)<-[:HAS_CREATOR]-(post:Message)
WHERE  1313579421570 < post.creationDate AND post.creationDate < 1342803345373
  AND  post.isPost = true
SELECT person, post, post AS message )

FROM     T
GROUP BY person  
SELECT   person.id, person.firstName, person.lastName, COUNT(DISTINCT post) AS threadCount, COUNT(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, person.id ASC
LIMIT    100;