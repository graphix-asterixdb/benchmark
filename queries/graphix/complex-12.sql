WITH tagClasses AS 
    ( FROM GRAPH snb.snbGraph
      MATCH (tc:TagClass)-[:IS_SUBCLASS_OF{1,5}]->(tagClass:TagClass)
      WHERE tagClass.name = 'Monarch'
      SELECT VALUE tc.name ) 

FROM  GRAPH snb.snbGraph
MATCH (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(comment:Message)-[:REPLY_OF]->(post:Message),
      (post)-[:M_HAS_TAG]->(tag:Tag)-[:HAS_TYPE]->(tc:TagClass)
WHERE person.id = 933 AND (tc.name IN tagClasses OR tc.name = 'Monarch') AND comment.isPost = false AND post.isPost = true
GROUP BY friend
GROUP AS g
SELECT 
    friend.id,
    friend.firstName,
    friend.lastName,
    (SELECT DISTINCT VALUE tag.name FROM g) AS tagNames,
    COUNT(DISTINCT comment) as replyCount    
ORDER BY replyCount DESC, friend.id ASC
LIMIT    20;