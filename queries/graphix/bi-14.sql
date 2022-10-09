WITH scores AS (
FROM      GRAPH snb.snbGraph
MATCH     (country1:Country)<-[:IS_PART_OF]-(city1:City)<-[:P_IS_LOCATED_IN]-(person1:Person)-[:KNOWS]-(person2:Person)-[:P_IS_LOCATED_IN]->(city2:City)-[:IS_PART_OF]->(country2:Country)
LET c1 =  EXISTS (FROM GRAPH snb.snbGraph
                  MATCH (person1)<-[:HAS_CREATOR]-(:Message)-[:REPLY_OF]->(:Message)-[:HAS_CREATOR]->(person2)
                  SELECT VALUE 1 ),
    c2 =  EXISTS (FROM GRAPH snb.snbGraph
                  MATCH (person1)<-[:HAS_CREATOR]-(:Message)<-[:REPLY_OF]-(:Message)-[:HAS_CREATOR]->(person2)
                  SELECT VALUE 1 ),
    c3 =  EXISTS (FROM GRAPH snb.snbGraph
                  MATCH (person1)-[:LIKES]->(:Message)-[:HAS_CREATOR]->(person2)
                  SELECT VALUE 1 ),
    c4 =  EXISTS (FROM GRAPH snb.snbGraph
                  MATCH (person1)<-[:HAS_CREATOR]-(:Message)<-[:LIKES]-(person2)
                  SELECT VALUE 1 )
WHERE     country1.name = 'Chile' AND country2.name = 'Argentina'
SELECT    DISTINCT person1.id AS person1id, person2.id AS person2id, city1.name AS city,
          (CASE (c1) WHEN true THEN 4  ELSE 0 END) +
          (CASE (c2) WHEN true THEN 1  ELSE 0 END) +
          (CASE (c3) WHEN true THEN 10 ELSE 0 END) +
          (CASE (c4) WHEN true THEN 1  ELSE 0 END) AS score )

FROM         scores S
GROUP BY     S.city
GROUP AS     g
LET result = ( FROM g gi
               SELECT gi.S.person1id, gi.S.person2id, gi.S.city, gi.S.score
               ORDER BY gi.S.score DESC
               LIMIT 1 )[0]
SELECT VALUE result
ORDER BY     result.score DESC, result.person1id ASC, result.person2id ASC;