DELETE FROM snb.Knows15;

INSERT   INTO snb.Knows15
FROM     GRAPH snb.snbGraph
MATCH    (personA:Person)-[:KNOWS]->(personB:Person)
LET w1 = (FROM GRAPH snb.snbGraph
          MATCH (personA)<-[:HAS_CREATOR]-(comment:Message)-[:REPLY_OF]->(post:Message)-[:HAS_CREATOR]->(personB),
                (post)<-[:CONTAINER_OF]-(forum:Forum)
          WHERE comment.isPost = false AND post.isPost = true AND
                forum.creationDate >= 1313579421570 AND forum.creationDate <= 1342803345373
          SELECT VALUE COUNT(comment) )[0],
    w2 = (FROM GRAPH snb.snbGraph
          MATCH (personA)<-[:HAS_CREATOR]-(post:Message)<-[:REPLY_OF]-(comment:Message)-[:HAS_CREATOR]->(personB),
                (post)<-[:CONTAINER_OF]-(forum:Forum)
          WHERE comment.isPost = false AND post.isPost = true AND
                forum.creationDate >= 1313579421570 AND forum.creationDate <= 1342803345373
          SELECT VALUE COUNT(comment) )[0],
    w3 = (FROM GRAPH snb.snbGraph
          MATCH (personA)<-[:HAS_CREATOR]-(c1:Message)-[:REPLY_OF]->(c2:Message)-[:HAS_CREATOR]->(personB),
                (c2)-[:REPLY_OF{1,2}]->(post:Message)<-[:CONTAINER_OF]-(forum:Forum)
          WHERE c1.isPost = false AND c2.isPost = false AND post.isPost = true AND
                forum.creationDate >= 1313579421570 AND forum.creationDate <= 1342803345373
          SELECT VALUE COUNT(c1) )[0],
    w4 = (FROM GRAPH snb.snbGraph
          MATCH (personA)<-[:HAS_CREATOR]-(c2:Message)<-[:REPLY_OF]-(c1:Message)-[:HAS_CREATOR]->(personB),
                (c2)-[:REPLY_OF{1,2}]->(post:Message)<-[:CONTAINER_OF]-(forum:Forum)
          WHERE c1.isPost = false AND c2.isPost = false AND post.isPost = true AND
                forum.creationDate >= 1313579421570 AND forum.creationDate <= 1342803345373
          SELECT VALUE COUNT(c1) )[0]
SELECT personA.id AS person1id, personB.id AS person2id, 1/(w1 + w2 + 0.5*(w3 + w4) + 1) AS weight;

FROM GRAPH snb.snbGraph
MATCH (person1:Person)-[k:KNOWS15{1,3}]-(person2:Person)
WHERE person1.id = 933 AND person2.id = 4398046512764
GROUP BY person1, person2
GROUP AS g
LET shortestPath = (
      FROM g gi
      SELECT ( FROM EDGES(gi.k) ke
               SELECT VALUE SUM(ke.weight) )[0] AS length
      ORDER BY length ASC
      LIMIT    1
    )[0]
SELECT shortestPath.length AS totalWeight
LIMIT 1;