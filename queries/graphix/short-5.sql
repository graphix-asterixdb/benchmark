FROM    GRAPH snb.snbGraph
MATCH   (message:Message)-[:HAS_CREATOR]->(person:Person)
WHERE   message.id = 618475290625
SELECT  person.id, person.firstName, person.lastName;