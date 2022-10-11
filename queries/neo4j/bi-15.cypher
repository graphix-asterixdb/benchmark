/*
:param [{ person1Id, person2Id, startDate, endDate }] => { RETURN
    933 AS person1Id,
    4398046512764 AS person2Id,
    1313579421570 AS startDate,
    1342803345373 AS endDate
}
*/ 
// copied from reference

MATCH (person1:Person {id: $person1Id}), (person2:Person {id: $person2Id})
CALL gds.shortestPath.dijkstra.stream({
  nodeQuery: 'MATCH (p:Person) RETURN id(p) AS id',
  relationshipQuery: '
    MATCH (pA:Person)-[knows:KNOWS]-(pB:Person)

    // case 1: every reply (by one of the Persons) to a Post (by the other Person) is worth 1.0 point
    OPTIONAL MATCH
      (pA)<-[:HAS_CREATOR]-(c:Comment)-[:REPLY_OF]->(post:Post)-[:HAS_CREATOR]->(pB),
      (post)<-[:CONTAINER_OF]-(forum:Forum)
    WHERE forum.creationDate >= $startDate
      AND forum.creationDate <= $endDate
    WITH knows, pA, pB, count(c)*1.0 AS w1

    // case 2: every reply (by ones of the Persons) to a Comment (by the other Person) is worth 0.5 points
    OPTIONAL MATCH
      (pA)<-[:HAS_CREATOR]-(c1:Comment)-[:REPLY_OF]->(c2:Comment)-[:HAS_CREATOR]->(pB),
      (c2)-[:REPLY_OF*]->(:Post)<-[:CONTAINER_OF]-(forum:Forum)
    WHERE forum.creationDate >= $startDate
      AND forum.creationDate <= $endDate
    WITH knows, pA, pB, w1+count(c1)*0.5 AS w2

    // case 1 reverse
    OPTIONAL MATCH
      (pA)<-[:HAS_CREATOR]-(post:Post)<-[:REPLY_OF]-(c:Comment)-[:HAS_CREATOR]->(pB),
      (post)<-[:CONTAINER_OF]-(forum:Forum)
    WHERE forum.creationDate >= $startDate
      AND forum.creationDate <= $endDate
    WITH knows, pA, pB, w2+count(c)*1.0 AS w3

    // case 2 reverse
    OPTIONAL MATCH
      (pA)<-[:HAS_CREATOR]-(c2:Comment)<-[:REPLY_OF]->(c1:Comment)-[:HAS_CREATOR]->(pB),
      (c2)-[:REPLY_OF*]->(:Post)<-[:CONTAINER_OF]-(forum:Forum)
    WHERE forum.creationDate >= $startDate
      AND forum.creationDate <= $endDate
    WITH knows, pA, pB, w3+count(c1)*0.5 AS w4

    RETURN
       id(pA) AS source,
       id(pB) AS target,
       1/(w4+1) AS weight
    ',
  sourceNode: person1,
  targetNode: person2,
  relationshipWeightProperty: 'weight'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN totalCost