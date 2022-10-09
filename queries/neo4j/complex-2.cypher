// :param personId: 933
// :param maxDate: 1313591219961

MATCH (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(message:Message)
WHERE person.id = $personId AND message.creationDate < $maxDate
RETURN
    friend.id,
    friend.firstName,
    friend.lastName,
    message.id,
    coalesce(message.content, message.imageFile) as content,
    message.creationDate
ORDER BY message.creationDate DESC, message.id ASC
LIMIT 20;