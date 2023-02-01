MATCH          (person:Person)
OPTIONAL MATCH (person)<-[:HAS_CREATOR]-(message:Message)-[:REPLY_OF*0..]->(post:Post)
WHERE          message.content IS NOT NULL AND 
               message.length < $lengthThreshold AND
               message.creationDate > $startDate AND
               post.language IN $languages
WITH           person,
               COUNT(message) AS messageCount
RETURN         messageCount,
               COUNT(person) AS personCount
ORDER BY       personCount DESC,
               messageCount DESC;
