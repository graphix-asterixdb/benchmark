SET       `graphix.semantics.pattern` "edge-isomorphism";

FROM GRAPH snb.snbGraph
MATCH (message:Message)<-[:REPLY_OF]-(comment:Message),
      (comment)-[:HAS_CREATOR]->(replyAuthor:Person),
      (message)-[:HAS_CREATOR]->(messageAuthor:Person)
LET knows1 = EXISTS ( FROM GRAPH snb.snbGraph
                      MATCH (replyAuthor)<-[:KNOWS]-(messageAuthor)
                      SELECT VALUE 1 ),
    knows2 = EXISTS ( FROM GRAPH snb.snbGraph
                      MATCH (replyAuthor)-[:KNOWS]->(messageAuthor)
                      SELECT VALUE 1 )
WHERE message.id = 1099511899880
SELECT DISTINCT
    comment.id AS commentId,
    comment.content,
    comment.creationDate AS commentCreationDate,
    replyAuthor.id AS replyAuthorId,
    replyAuthor.firstName,
    replyAuthor.lastName,
    knows1 OR knows2 AS knows
ORDER BY comment.creationDate DESC, replyAuthor.id ASC;