MATCH (:Person {id: $personId })-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(message:Message)
    WHERE message.creationDate <= $maxDate
    RETURN
        friend.id AS personId,
        friend.firstName AS personFirstName,
        friend.lastName AS personLastName,
        message.id AS postOrCommentId,
        coalesce(message.content,message.imageFile) AS postOrCommentContent,
        message.creationDate AS postOrCommentCreationDate
    ORDER BY
        postOrCommentCreationDate DESC,
        toInteger(postOrCommentId) ASC
    LIMIT 20