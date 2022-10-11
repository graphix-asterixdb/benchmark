// :param personId: 933

MATCH (person:Person)<-[:HAS_CREATOR]-(message:Message)<-[likes:LIKES]-(friend:Person)
WHERE person.id = $personId
WITH person, message, likes, friend
ORDER BY likes.creationDate DESC, message.id ASC
WITH person, friend, HEAD(COLLECT({likeDate: likes.creationDate, message:message})) as likeInfo
RETURN
    friend.id,
    friend.firstName,
    friend.lastName,
    likeInfo.likeDate,
    likeInfo.message.id,
    coalesce(likeInfo.message.content, likeInfo.message.imageFile),
    (likeInfo.likeDate - likeInfo.message.creationDate)/60000 AS minutesLatency,
    NOT exists((person)-[:KNOWS]-(friend)) AS isNew
ORDER BY likeInfo.likeDate DESC, friend.id ASC
LIMIT 20;