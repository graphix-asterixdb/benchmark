DELETE FROM snb.Knows14;

INSERT INTO snb.Knows14
FROM     GRAPH snb.snbGraph
MATCH    (personA:Person)-[:KNOWS]-(personB:Person),
         (personA)<-[:HAS_CREATOR]-(m1:Message)-[:REPLY_OF]-(m2:Message)-[:HAS_CREATOR]->(personB)
GROUP BY personA, personB
GROUP AS g
SELECT   personA.id AS person1id, personB.id AS person2id, 
         (SELECT VALUE COUNT(*) FROM g gi WHERE gi.m1.isPost = true OR gi.m2.isPost = true)[0] +
         (SELECT VALUE COUNT(*) FROM g gi WHERE gi.m1.isPost = false AND gi.m2.isPost = false)[0] * 0.5 AS weight;

FROM     GRAPH snb.snbGraph
MATCH    (person1:Person)-[k:KNOWS14{1,4}]->(person2:Person)
WHERE    person1.id = 933 AND person2.id = 102
GROUP BY person1, person2
GROUP AS g
LET shortestPath = (
      FROM g gi
      SELECT ( FROM VERTICES(gi.k) kv SELECT VALUE kv.id ) AS ids,
             ( FROM EDGES(gi.k) ke SELECT VALUE SUM(ke.weight) )[0] AS length
      ORDER BY PATH_HOP_COUNT(gi.k) ASC
      LIMIT    1
    )[0]
SELECT   shortestPath.ids AS personIdsInPath, shortestPath.length AS pathWeight
ORDER BY pathWeight DESC;
