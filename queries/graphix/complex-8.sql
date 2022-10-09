FROM   GRAPH snb.snbGraph
MATCH  (person:Person)<-[:HAS_CREATOR]-(message:Message)<-[:REPLY_OF]-(comment:Message)-[:HAS_CREATOR]->(commentAuthor:Person)
WHERE  person.id = 933 AND comment.isPost = false
SELECT
    commentAuthor.id AS authorId,
    commentAuthor.firstName,
    commentAuthor.lastName,
    comment.creationDate,
    comment.id AS commentId,
    comment.content
ORDER BY comment.creationDate DESC, commentId ASC
LIMIT    20;