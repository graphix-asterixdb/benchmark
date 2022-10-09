// :param messageId: 618475290625

MATCH (message:Message)-[:HAS_CREATOR]->(person:Person)
WHERE message.id = $messageId
RETURN person.id, person.firstName, person.lastName;