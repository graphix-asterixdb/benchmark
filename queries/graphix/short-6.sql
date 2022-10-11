FROM   GRAPH snb.snbGraph
MATCH  (message:Message)-[:REPLY_OF{1,5}]->(post:Message)<-[:CONTAINER_OF]-(forum:Forum)-[:HAS_MODERATOR]->(moderator:Person)
WHERE  message.id = 618475290625 AND post.isPost = true
SELECT forum.id AS forumId, forum.title, moderator.id AS moderatorId, moderator.firstName, moderator.lastName

UNION ALL

FROM   GRAPH snb.snbGraph
MATCH  (post:Message)<-[:CONTAINER_OF]-(forum:Forum)-[:HAS_MODERATOR]->(moderator:Person)
WHERE  post.id = 618475290625 AND post.isPost = true
SELECT forum.id AS forumId, forum.title, moderator.id AS moderatorId, moderator.firstName, moderator.lastName