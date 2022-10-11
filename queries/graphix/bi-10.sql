SET       `graphix.semantics.pattern` "edge-isomorphism";

WITH ids AS (
    FROM     GRAPH snb.snbGraph
    MATCH    (person:Person)-[k:KNOWS{1,4}]-(iexpertCandidatePerson:Person)
    WHERE    person.id = 933
    GROUP BY person, iexpertCandidatePerson
    HAVING   MIN(PATH_HOP_COUNT(k)) >= 3
    SELECT   VALUE iexpertCandidatePerson.id
)

FROM GRAPH snb.snbGraph
MATCH
    (expertCandidatePerson:Person)-[:P_IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(country:Country),
    (expertCandidatePerson)<-[:HAS_CREATOR]-(message:Message)-[:M_HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagClass:TagClass),
    (message)-[:M_HAS_TAG]->(tag:Tag)
WHERE    country.name = 'China' AND tagClass.name = 'MusicalArtist' AND expertCandidatePerson.id IN ids
GROUP BY expertCandidatePerson, tag
SELECT   expertCandidatePerson.id, tag.name, COUNT(DISTINCT message) AS messageCount
ORDER BY messageCount DESC, tag.name ASC, expertCandidatePerson.id ASC
LIMIT    100;