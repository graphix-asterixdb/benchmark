// :param personId: 933
// :param month: 3

MATCH (person:Person)-[:KNOWS*2..2]-(foaf:Person)-[:IS_LOCATED_IN]->(city:City)
WHERE person.id = $personId AND NOT exists((person)-[:KNOWS]-(foaf)) AND NOT foaf=person
WITH person, foaf, city, datetime({epochmillis: foaf.birthday}) AS bd
WHERE (bd.month = $month AND bd.day >= 21) OR (bd.month = ($month%12)+1 AND bd.day < 22)
OPTIONAL MATCH (person)-[:HAS_INTEREST]->(tag:Tag)<-[:HAS_TAG]-(post:Post)-[:HAS_CREATOR]->(foaf)
WITH person, foaf, city, COUNT(DISTINCT post) as common
OPTIONAL MATCH (post:Post)-[:HAS_CREATOR]->(foaf)
WHERE NOT exists((person)-[:HAS_INTEREST]->(:Tag)<-[:HAS_TAG]-(post))
WITH person, foaf, city, common, COUNT(DISTINCT post) as uncommon
RETURN
    foaf.id,
    foaf.firstName,
    foaf.lastName,
    common - uncommon as commonInterestScore,
    foaf.gender,
    city.name
ORDER BY commonInterestScore DESC, foaf.id ASC
LIMIT 10;