FROM  GRAPH snb.snbGraph
MATCH (person:Person)-[:KNOWS{1,2}]-(otherPerson:Person),
      (otherPerson)<-[:HAS_CREATOR]-(m1:Message)-[:M_IS_LOCATED_IN]->(countryX:Country),
      (otherPerson)<-[:HAS_CREATOR]-(m2:Message)-[:M_IS_LOCATED_IN]->(countryY:Country),
      (otherPerson)-[:P_IS_LOCATED_IN]->(city:City)
WHERE person.id = 933 AND
      1275393600000 <= m1.creationDate AND m1.creationDate < 1275393600000 + 365 * 86400000 AND
      1275393600000 <= m2.creationDate AND m2.creationDate < 1275393600000 + 365 * 86400000 AND
      countryX.name = 'India' AND countryY.name = 'China' AND 
      NOT EXISTS ( FROM GRAPH snb.snbGraph 
                   MATCH (city)-[:IS_PART_OF]->(countryX)
                   SELECT VALUE 1 ) AND 
      NOT EXISTS ( FROM GRAPH snb.snbGraph 
                   MATCH (city)-[:IS_PART_OF]->(countryY)
                   SELECT VALUE 1 )
GROUP BY otherPerson
SELECT
    otherPerson.id,
    otherPerson.firstName,
    otherPerson.lastName,
    COUNT(DISTINCT m1) AS xCount,
    COUNT(DISTINCT m2) AS yCount,
    COUNT(DISTINCT m1) + COUNT(DISTINCT m2) AS count
ORDER BY count DESC, otherPerson.id ASC
LIMIT    20;

