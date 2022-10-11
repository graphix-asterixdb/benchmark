// :param messageId: 618475290625

MATCH (message:Message)-[:REPLY_OF*0..]->(post:Post)<-[:CONTAINER_OF]-(forum:Forum)-[:HAS_MODERATOR]->(moderator:Person)
WHERE message.id = $messageId
RETURN forum.id, forum.title, moderator.id, moderator.firstName, moderator.lastName;