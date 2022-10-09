FROM   GRAPH snb.snbGraph
MATCH  (person:Person)-[:KNOWS{1,2}]-(otherPerson:Person)<-[:HAS_CREATOR]-(message:Message)
WHERE  person.id = 933 AND message.creationDate < 1342803345373
SELECT DISTINCT
    otherPerson.id AS otherPersonId,
    otherPerson.firstName,
    otherPerson.lastName,
    message.id AS messageId,
    coalesce(message.content, message.imageFile) AS content,
    message.creationDate
ORDER BY message.creationDate DESC, message.id ASC
LIMIT    20;