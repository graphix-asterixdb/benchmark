WITH topMessages AS
    ( FROM GRAPH snb.snbGraph
      MATCH (person:Person)<-[:HAS_CREATOR]-(message:Message)
      WHERE person.id = 933
      SELECT VALUE message.id
      ORDER BY message.creationDate DESC
      LIMIT 10 )

FROM (      
FROM   GRAPH snb.snbGraph
MATCH  (message:Message)-[:REPLY_OF{1,3}]->(post:Message)-[:HAS_CREATOR]->(originalPoster:Person)
WHERE  post.isPost = true AND message.id IN topMessages
SELECT
    message.id AS messageID,
    coalesce(message.content, message.imageFile) AS content,
    message.creationDate,
    post.id AS postID,
    originalPoster.id AS originalPosterID,
    originalPoster.firstName,
    originalPoster.lastName

UNION ALL 
      
FROM   GRAPH snb.snbGraph
MATCH  (post:Message)-[:HAS_CREATOR]->(originalPoster:Person)
WHERE  post.isPost = true AND post.id IN topMessages
SELECT
    post.id AS messageID,
    coalesce(post.content, post.imageFile) AS content,
    post.creationDate,
    post.id AS postID,
    originalPoster.id AS originalPosterID,
    originalPoster.firstName,
    originalPoster.lastName ) T
SELECT VALUE T
ORDER BY     T.creationDate DESC, T.messageID DESC
LIMIT        10;      