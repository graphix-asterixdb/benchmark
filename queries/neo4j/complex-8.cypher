// :param personId: 933

MATCH (person:Person)<-[:HAS_CREATOR]-(message:Message)<-[:REPLY_OF]-(comment:Comment)-[:HAS_CREATOR]->(commentAuthor:Person)
WHERE person.id = $personId
RETURN
    commentAuthor.id,
    commentAuthor.firstName,
    commentAuthor.lastName,
    comment.creationDate,
    comment.id,
    comment.content
ORDER BY comment.creationDate DESC, comment.id ASC
LIMIT 20;