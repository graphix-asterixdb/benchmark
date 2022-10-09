// :param personId: 933
// :param firstName: 'Jack'

MATCH path = (person:Person)-[:KNOWS*1..3]-(otherPerson:Person)
WHERE person.id = $personId AND otherPerson.firstName = $firstName AND person <> otherPerson
WITH otherPerson, MIN(LENGTH(path)) as distanceFromPerson
MATCH (otherPerson)-[:IS_LOCATED_IN]->(locationCity:City)
OPTIONAL MATCH (otherPerson)-[w:WORK_AT]->(company:Company)-[:IS_LOCATED_IN]->(companyCountry:Country)
WITH otherPerson, locationCity, distanceFromPerson,
    COLLECT([company.name, w.workFrom, companyCountry.name]) as companies
OPTIONAL MATCH (otherPerson)-[s:STUDY_AT]->(university:University)-[:IS_LOCATED_IN]->(universityCity:City)
WITH otherPerson, locationCity, distanceFromPerson, companies,
    COLLECT([university.name, s.classYear, universityCity.name]) as universities
RETURN
    otherPerson.id,
    otherPerson.lastName,
    distanceFromPerson,
    otherPerson.birthday,
    otherPerson.creationDate,
    otherPerson.gender,
    otherPerson.browserUsed,
    otherPerson.locationIP,
    otherPerson.email,
    otherPerson.speaks,
    locationCity.name,
    universities,
    companies
ORDER BY distanceFromPerson ASC, otherPerson.lastName ASC, otherPerson.id ASC
LIMIT 20;
