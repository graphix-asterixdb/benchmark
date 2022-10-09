FROM     GRAPH snb.snbGraph
MATCH    (person:Person)-[:KNOWS{1,2}]-(otherPerson:Person)<-[h:HAS_MEMBER]-(forum:Forum)-[:CONTAINER_OF]->(post:Message),
         (post)-[:HAS_CREATOR]->(otherPerson)
WHERE    person.id = 933 AND h.joinDate > 1313579421570 AND post.isPost = true
GROUP BY forum
SELECT   forum.title, COUNT(DISTINCT post) AS postCount
ORDER BY postCount DESC, forum.id ASC
LIMIT    20;