// :param personId: 933
// :param startDate: 1275393600000
// :param durationDays: 365
// :param countryXName: 'India'
// :param countryYName: 'China'

MATCH (person:Person)-[:KNOWS*1..2]-(otherPerson:Person)
WHERE person.id = $personId
MATCH (otherPerson)<-[:HAS_CREATOR]-(m1:Message)-[:IS_LOCATED_IN]->(countryX:Country)
WHERE $startDate <= m1.creationDate AND m1.creationDate < $startDate + $durationDays * 86400000 AND countryX.name = $countryXName
MATCH (otherPerson)<-[:HAS_CREATOR]-(m2:Message)-[:IS_LOCATED_IN]->(countryY:Country)
WHERE $startDate <= m2.creationDate AND m2.creationDate < $startDate + $durationDays * 86400000 AND countryY.name = $countryYName
MATCH (otherPerson)-[:IS_LOCATED_IN]->(city:City)
WHERE NOT exists((city)-[:IS_PART_OF]->(countryX)) AND NOT exists((city)-[:IS_PART_OF]->(countryY))
WITH otherPerson, COUNT(DISTINCT m1) as xCount, COUNT(DISTINCT m2) as yCount
RETURN
    otherPerson.id,
    otherPerson.firstName,
    otherPerson.lastName,
    xCount,
    yCount,
    xCount + yCount AS count
ORDER BY count DESC, otherPerson.id ASC
LIMIT 20;