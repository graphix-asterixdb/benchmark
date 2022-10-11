// :param tag: Abbas_I_of_Persia

MATCH (tag:Tag)<-[:HAS_TAG]-(m:Message)-[:HAS_CREATOR]->(person:Person)
WHERE tag.name = $tag
OPTIONAL MATCH (liker:Person)-[:LIKES]->(m)
OPTIONAL MATCH (comment:Comment)-[:REPLY_OF]->(m)
WITH person, COUNT(DISTINCT m) AS messageCount, COUNT(DISTINCT liker) AS likeCount, COUNT(DISTINCT comment) AS replyCount
RETURN person.id, replyCount, likeCount, messageCount, messageCount + 2 * replyCount + 10 * likeCount AS score
ORDER BY score DESC, person.id ASC
LIMIT 100;