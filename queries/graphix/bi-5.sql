FROM       GRAPH snb.snbGraph
MATCH      (tag:Tag)<-[:M_HAS_TAG]-(m:Message)-[:HAS_CREATOR]->(person:Person)
LEFT MATCH (liker:Person)-[:LIKES]->(m)
LEFT MATCH (comment:Message)-[:REPLY_OF]->(m)
WHERE      tag.name = 'Abbas_I_of_Persia'
GROUP BY   person
LET        messageCount = COUNT(DISTINCT m), likeCount = COUNT(DISTINCT liker), replyCount = COUNT(DISTINCT comment)
SELECT     person.id, replyCount, likeCount, messageCount, messageCount + 2 * replyCount + 10 * likeCount AS score
ORDER BY   score DESC, person.id ASC
LIMIT      100;