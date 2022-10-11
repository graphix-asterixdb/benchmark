WITH table AS
( FROM       GRAPH snb.snbGraph
  MATCH      (person:Person)
  LEFT MATCH (person)<-[:HAS_CREATOR]-(message:Message)-[:REPLY_OF{1,4}]->(post:Message)
  WHERE      message.content IS NOT NULL
    AND      message.length < 20
    AND      message.creationDate > 1313579421570
    AND      post.language IN ['ar', 'hu']
    AND      post.isPost = true
  SELECT     person, message
 
  UNION ALL
 
  FROM       GRAPH snb.snbGraph
  MATCH      (person:Person)
  LEFT MATCH (person)<-[:HAS_CREATOR]-(post:Message)
  WHERE      post.content IS NOT NULL
    AND      post.length < 20
    AND      post.creationDate > 1313579421570
    AND      post.language IN ['ar', 'hu']
    AND      post.isPost = true
  SELECT     person, post AS message ),
  
temp AS 
( FROM table T
  GROUP BY person
  SELECT person, COUNT(message) AS messageCount ) 

FROM     temp T
GROUP BY T.messageCount
SELECT   T.messageCount, COUNT(T.person) AS personCount
ORDER BY personCount DESC, messageCount DESC;