DELETE FROM snb.Knows19;

INSERT INTO snb.Knows19
FROM        GRAPH snb.snbGraph
MATCH       (personA:Person)-[:KNOWS]-(personB:Person),
            (personA)<-[:HAS_CREATOR]-(:Message)-[:REPLY_OF]-(:Message)-[:HAS_CREATOR]->(personB)
GROUP BY    personA, personB
SELECT      personA.id AS person1id, personB.id AS person2id, 1/COUNT(*) AS weight;

FROM      GRAPH snb.snbGraph
MATCH     (city1:City)<-[:P_IS_LOCATED_IN]-(person1:Person)-[k:KNOWS19{1,4}]->(person2:Person)-[:P_IS_LOCATED_IN]->(city2:City)
WHERE     city1.id = 669 AND city2.id = 755
GROUP BY  person1, person2
GROUP AS  g
LET shortestPath = (
      FROM g gi
      SELECT ( FROM EDGES(gi.k) ke
               SELECT VALUE SUM(ke.weight) )[0] AS length
      ORDER BY length ASC
      LIMIT    1
    )[0]
SELECT    person1.id AS person1id, person2.id AS person2id, shortestPath.length AS totalWeight
ORDER BY  person1id ASC, person2id ASC;