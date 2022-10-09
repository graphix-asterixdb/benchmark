// :param personId: 933
// :param countryName: 'China'
// :param workFromYear: 2010

MATCH (person:Person)-[:KNOWS*1..2]-(otherPerson:Person)-[w:WORK_AT]->(company:Company)-[:IS_LOCATED_IN]->(country:Country)
WHERE person.id = $personId AND w.workFrom < $workFromYear AND country.name = $countryName
RETURN DISTINCT
    otherPerson.id,
    otherPerson.firstName,
    otherPerson.lastName,
    company.name,
    w.workFrom
ORDER BY w.workFrom ASC, otherPerson.id ASC, company.name DESC
LIMIT 10;
