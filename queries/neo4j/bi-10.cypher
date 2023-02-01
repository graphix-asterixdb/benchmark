MATCH    (startPerson:Person {id: $personId})
CALL     apoc.path.subgraphNodes(startPerson, {
	         relationshipFilter: "KNOWS",
             minLevel: 1,
             maxLevel: $minPathDistance-1
         })
YIELD    node
WITH     startPerson,
         COLLECT(DISTINCT node) AS nodesCloserThanMinPathDistance
CALL     apoc.path.subgraphNodes(startPerson, {
             relationshipFilter: "KNOWS",
             minLevel: 1,
             maxLevel: $maxPathDistance
         })
YIELD    node
WITH     nodesCloserThanMinPathDistance,
         COLLECT(DISTINCT node) AS nodesCloserThanMaxPathDistance
WITH     [n IN nodesCloserThanMaxPathDistance WHERE NOT n IN nodesCloserThanMinPathDistance] AS expertCandidatePersons
UNWIND   expertCandidatePersons AS expertCandidatePerson
MATCH    (expertCandidatePerson)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(:Country {name: $country}),
         (expertCandidatePerson)<-[:HAS_CREATOR]-(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->
         (:TagClass {name: $tagClass})
MATCH    (message)-[:HAS_TAG]->(tag:Tag)
RETURN   expertCandidatePerson.id,
         tag.name,
         COUNT(DISTINCT message) AS messageCount
ORDER BY messageCount DESC,
         tag.name ASC,
         expertCandidatePerson.id ASC
LIMIT    $limit;
