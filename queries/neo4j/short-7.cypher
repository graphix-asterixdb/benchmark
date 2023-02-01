MATCH    (message:Message)<-[:REPLY_OF]-(comment:Comment),
         (comment)-[:HAS_CREATOR]->(replyAuthor:Person),
         (message)-[:HAS_CREATOR]->(messageAuthor:Person)
WHERE    message.id = $messageId
RETURN   comment.id,
         comment.content,
         comment.creationDate,
         replyAuthor.id,
         replyAuthor.firstName,
         replyAuthor.lastName,
         EXISTS((replyAuthor)-[:KNOWS]-(messageAuthor)) as knows
ORDER BY comment.creationDate DESC,
         replyAuthor.id ASC;
