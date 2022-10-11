DELETE FROM snb.Knows20;

INSERT INTO snb.Knows20
FROM        GRAPH snb.snbGraph
MATCH       (personA:Person)-[:KNOWS]-(personB:Person),
            (personA)-[saA:STUDY_AT]->(:University)<-[saB:STUDY_AT]-(personB)
GROUP BY    personA, personB
GROUP AS    g
SELECT      personA.id AS person1id, personB.id AS person2id,
            (SELECT VALUE MIN(ABS(gi.saA.classYear - gi.saB.classYear)) + 1 FROM g gi)[0] AS weight;

WITH temp AS (
  FROM     GRAPH snb.snbGraph
  MATCH    (company:Company)<-[:WORK_AT]-(person1:Person)-[k:KNOWS20{1,4}]->(person2:Person)
  WHERE    company.name = 'Air_Madagascar' AND person2.id = 102
  GROUP BY person1, person2
  GROUP AS g
  LET shortestPath = (
        FROM g gi
        SELECT ( FROM EDGES(gi.k) ke
                SELECT VALUE SUM(ke.weight) )[0] AS length
        ORDER BY length ASC
        LIMIT    1
      )[0]
  SELECT   person1.id AS person1id, shortestPath.length AS totalWeight
  ORDER BY totalWeight ASC, person1id ASC)

SELECT VALUE T FROM temp T WHERE T.totalWeight = (SELECT VALUE MIN(ti.totalWeight) FROM temp ti)[0];