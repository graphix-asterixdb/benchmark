// :param personId: 933

MATCH (person:Person)<-[:HAS_CREATOR]-(message:Message)
WHERE person.id = $personId
WITH person, message
ORDER BY message.creationDate DESC
LIMIT 10
MATCH (message)-[:REPLY_OF*0..]->(post:Post)-[:HAS_CREATOR]->(originalPoster:Person)
RETURN
    message.id,
    coalesce(message.content, message.imageFile),
    message.creationDate,
    post.id,
    originalPoster.id,
    originalPoster.firstName,
    originalPoster.lastName
ORDER BY message.creationDate DESC, message.id DESC;