FROM   GRAPH snb.snbGraph
MATCH  (country:Country),
       (a:Person)-[:P_IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
       (b:Person)-[:P_IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
       (c:Person)-[:P_IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
       (a)-[k1:KNOWS]-(b)-[k2:KNOWS]-(c)-[k3:KNOWS]-(a)
WHERE  country.name = 'China' AND a.id < b.id AND b.id < c.id
  AND  1332803345373 <= k1.creationDate AND k1.creationDate <= 1342803345373
  AND  1332803345373 <= k2.creationDate AND k2.creationDate <= 1342803345373
  AND  1332803345373 <= k3.creationDate AND k3.creationDate <= 1342803345373
SELECT VALUE COUNT(DISTINCT [a,b,c]);