WITH topForums AS (
FROM 
( FROM GRAPH snb.snbGraph
  MATCH (country:Country)<-[:IS_PART_OF]-(city:City)<-[:P_IS_LOCATED_IN]-(member:Person)<-[:HAS_MEMBER]-(forum:Forum)
  WHERE forum.creationDate > 1313579421570
  GROUP BY forum, country
  SELECT forum, country, COUNT(member) as memberCount ) AS T
GROUP BY T.forum
SELECT VALUE T.forum.id
ORDER BY MAX(T.memberCount) DESC
LIMIT 100 ),

T AS (
FROM GRAPH snb.snbGraph
MATCH (person:Person)<-[:HAS_MEMBER]-(forum2:Forum)
LEFT MATCH (forum1:Forum WHERE forum1.id IN topForums)-[:CONTAINER_OF]->(post:Message WHERE post.isPost = true)<-[:REPLY_OF{1,4}]-(message:Message)-[:HAS_CREATOR]->(person)
WHERE forum2.id IN topForums
SELECT person, message

UNION ALL 

FROM GRAPH snb.snbGraph
MATCH (person:Person)<-[:HAS_MEMBER]-(forum2:Forum)
LEFT MATCH (forum1:Forum WHERE forum1.id IN topForums)-[:CONTAINER_OF]->(message:Message WHERE message.isPost = true)-[:HAS_CREATOR]->(person)
WHERE forum2.id IN topForums
SELECT person, message )

FROM     T
GROUP BY person
SELECT   person.id, person.firstName, person.lastName, person.creationDate, COUNT(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, person.id ASC
LIMIT    100;