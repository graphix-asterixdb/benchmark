// :param country: 'China'
// :param startDate: 1332803345373
// :param endDate: 1342803345373

MATCH
(a:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country:Country),
(b:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
(c:Person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country),
(a)-[k1:KNOWS]-(b)-[k2:KNOWS]-(c)-[k3:KNOWS]-(a)
WHERE a.id < b.id AND b.id < c.id
  AND $startDate <= k1.creationDate AND k1.creationDate <= $endDate
  AND $startDate <= k2.creationDate AND k2.creationDate <= $endDate
  AND $startDate <= k3.creationDate AND k3.creationDate <= $endDate
  AND country.name = $country
WITH DISTINCT a,b,c
RETURN COUNT(*) AS count