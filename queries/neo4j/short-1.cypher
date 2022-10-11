// :param personId: 933

MATCH (person:Person)-[:IS_LOCATED_IN]->(city:City)
WHERE person.id = $personId
RETURN 
    person.firstName,
    person.lastName,
    person.birthday,
    person.locationIP,
    person.browserUsed,
    city.id,
    person.gender,
    person.creationDate;