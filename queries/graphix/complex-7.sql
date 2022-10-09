FROM     GRAPH snb.snbGraph
MATCH    (person:Person)<-[:HAS_CREATOR]-(message:Message)<-[likes:LIKES]-(friend:Person)
WHERE    person.id = 933
GROUP BY person, friend
GROUP AS g
LET likeInfo = ( FROM g gi
                 SELECT gi.likes.creationDate, gi.message
                 ORDER BY gi.likes.creationDate DESC, gi.message.id ASC
                 LIMIT 1 )[0],
  isNew1 = NOT EXISTS ( FROM GRAPH snb.snbGraph
                        MATCH (person)-[:KNOWS]->(friend)
                        SELECT VALUE 1 ),
  isNew2 = NOT EXISTS ( FROM GRAPH snb.snbGraph
                        MATCH (person)<-[:KNOWS]-(friend)
                        SELECT VALUE 1 )                     
SELECT
    friend.id AS friendId,
    friend.firstName,
    friend.lastName,
    likeInfo.creationDate,
    likeInfo.message.id AS messageId,
    coalesce(likeInfo.message.content, likeInfo.message.imageFile) AS content,
    (likeInfo.creationDate - likeInfo.message.creationDate)/60000 AS minutesLatency,
    isNew1 AND isNew2 AS isNew
ORDER BY likeInfo.creationDate DESC, friendId ASC
LIMIT 20;