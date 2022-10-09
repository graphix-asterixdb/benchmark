WITH T AS (

FROM   GRAPH snb.snbGraph
MATCH  (country:Country)<-[:IS_PART_OF]-(:City)<-[:P_IS_LOCATED_IN]-(person:Person)<-[:HAS_MODERATOR]-(forum:Forum)-[:CONTAINER_OF]->(post:Message),
       (post)<-[:REPLY_OF{1,5}]-(message:Message)-[:M_HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagClass1:TagClass)
WHERE  country.name = 'Russia' AND post.isPost = true AND tagClass1.name = 'Politician'
SELECT forum, person, message AS message

UNION ALL

FROM   GRAPH snb.snbGraph
MATCH  (country:Country)<-[:IS_PART_OF]-(:City)<-[:P_IS_LOCATED_IN]-(person:Person)<-[:HAS_MODERATOR]-(forum:Forum)-[:CONTAINER_OF]->(post:Message),
       (post)-[:M_HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagClass2:TagClass)
WHERE  country.name = 'Russia' AND post.isPost = true AND tagClass2.name = 'Politician'
SELECT forum, person, post AS message )

FROM     T
GROUP BY forum, person
SELECT   forum.id AS forumId, forum.title, forum.creationDate, person.id AS personId, COUNT(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, forumId ASC
LIMIT    20;