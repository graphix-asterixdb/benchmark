FROM   GRAPH snb.snbGraph
MATCH  (person:Person)-[:KNOWS{1,2}]-(otherPerson:Person)-[w:WORK_AT]->(company:Company)-[:C_IS_LOCATED_IN]->(country:Country)
WHERE  person.id = 933 AND w.workFrom < 2010 AND country.name = 'China'
SELECT DISTINCT
    otherPerson.id,
    otherPerson.firstName,
    otherPerson.lastName,
    company.name,
    w.workFrom
ORDER BY w.workFrom ASC, otherPerson.id ASC, company.name DESC
LIMIT    10;
