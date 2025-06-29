MATCH (person:Person {id: $personId})<-[:HAS_CREATOR]-(message:Message)<-[like:LIKES]-(liker:Person)
    WITH liker, message, like.creationDate AS likeTime, person
    ORDER BY likeTime DESC, toInteger(message.id) ASC
    WITH liker, head(collect({msg: message, likeTime: likeTime})) AS latestLike, person
RETURN
    liker.id AS personId,
    liker.firstName AS personFirstName,
    liker.lastName AS personLastName,
    latestLike.likeTime AS likeCreationDate,
    latestLike.msg.id AS commentOrPostId,
    coalesce(latestLike.msg.content, latestLike.msg.imageFile) AS commentOrPostContent,
    duration.between(latestLike.likeTime, latestLike.msg.creationDate).minutes AS minutesLatency,
    not((liker)-[:KNOWS]-(person)) AS isNew
ORDER BY
    likeCreationDate DESC,
    toInteger(personId) ASC
LIMIT 20