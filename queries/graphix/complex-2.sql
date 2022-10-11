FROM      GRAPH snb.snbGraph
MATCH     (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(message:Message)
WHERE     person.id = 933 AND message.creationDate < 1313591219961
SELECT
    friend.id AS friendId,
    friend.firstName,
    friend.lastName,
    message.id as messageId,
    coalesce(message.content, message.imageFile) as content,
    message.creationDate
ORDER BY  message.creationDate DESC, messageId ASC
LIMIT     20;