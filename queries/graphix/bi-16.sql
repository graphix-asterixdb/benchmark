WITH T AS (
FROM      GRAPH snb.snbGraph
MATCH     (person1:Person)<-[:HAS_CREATOR]-(message1:Message)-[:M_HAS_TAG]->(tag:Tag)
LET cp2 = (FROM GRAPH snb.snbGraph
           MATCH (person1)-[:KNOWS]-(person2:Person)<-[:HAS_CREATOR]-(message2:Message)-[:M_HAS_TAG]->(tag)
           WHERE get_day(datetime_from_unix_time_in_ms(message2.creationDate)) =
                 get_day(datetime_from_unix_time_in_ms(1347778800000))
           SELECT VALUE COUNT(DISTINCT person2))[0]
WHERE      tag.name = 'Hamid_Karzai' AND cp2 < 20 AND get_year(datetime_from_unix_time_in_ms(message1.creationDate)) = 2012
GROUP BY   person1
SELECT     person1.id, COUNT(DISTINCT message1) AS messageCountA, 0 AS messageCountB

UNION ALL

FROM      GRAPH snb.snbGraph
MATCH     (person1:Person)<-[:HAS_CREATOR]-(message1:Message)-[:M_HAS_TAG]->(tag:Tag)
LET cp2 = (FROM GRAPH snb.snbGraph
           MATCH (person1)-[:KNOWS]-(person2:Person)<-[:HAS_CREATOR]-(message2:Message)-[:M_HAS_TAG]->(tag)
           WHERE get_day(datetime_from_unix_time_in_ms(message2.creationDate)) = 
                 get_day(datetime_from_unix_time_in_ms(1336460400000))
           SELECT VALUE COUNT(DISTINCT person2))[0]
WHERE      tag.name = 'Rumi' AND cp2 < 20 AND get_year(datetime_from_unix_time_in_ms(message1.creationDate)) = 2012
GROUP BY   person1
SELECT     person1.id, 0 AS messageCountA, COUNT(DISTINCT message1) AS messageCountB )

FROM       T
GROUP BY   T.id
SELECT     T.id, SUM(messageCountA) AS messageCountA, SUM(messageCountB) AS messageCountB
ORDER BY   messageCountA + messageCountB DESC, T.id ASC
LIMIT      20;