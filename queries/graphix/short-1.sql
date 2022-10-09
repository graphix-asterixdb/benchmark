FROM   GRAPH snb.snbGraph
MATCH  (person:Person)-[:P_IS_LOCATED_IN]->(city:City)
WHERE  person.id = 933
SELECT
    person.firstName,
    person.lastName,
    person.birthday,
    person.locationIP,
    person.browserUsed,
    city.id,
    person.gender,
    person.creationDate;