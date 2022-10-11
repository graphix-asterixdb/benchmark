WITH temp AS (
FROM 
( FROM GRAPH snb.snbGraph
  MATCH (tag:Tag)<-[:HAS_INTEREST]-(person:Person)
  WHERE tag.name = 'Hamid_Karzai'
  SELECT person.id, 100 AS score

  UNION ALL

  FROM GRAPH snb.snbGraph
  MATCH (tag:Tag)<-[:M_HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person:Person)
  WHERE tag.name = 'Hamid_Karzai' AND message.creationDate > 1313579421570 AND message.creationDate < 1342803345373
  GROUP BY person
  SELECT person.id, COUNT(message) AS score ) AS T

GROUP BY T.id
SELECT T.id, sum(T.score) AS score )

FROM       GRAPH snb.snbGraph
MATCH      (p1:Person)
LEFT MATCH (p1)-[:KNOWS]-(p2:Person)
LET        score = (SELECT VALUE t.score FROM temp t WHERE t.id = p1.id)[0],
           friendScore = (SELECT VALUE t.score FROM temp t WHERE t.id = p2.id)[0]
WHERE      p1.id IN (SELECT VALUE t.id FROM temp t)
GROUP BY   p1, score
SELECT
  p1.id AS id1,
  score,
  SUM(friendScore) AS friendsScore
ORDER BY   score + friendsScore DESC, p1.id ASC
LIMIT      100;