// :param startDate: 1313579421570
// :param endDate: 1342803345373

MATCH (person:Person)<-[:HAS_CREATOR]-(post:Post)<-[:REPLY_OF*0..]-(message:Message)
WHERE $startDate < post.creationDate AND post.creationDate < $endDate
  AND $startDate < message.creationDate AND message.creationDate < $endDate
WITH person, COUNT(DISTINCT post) as threadCount, COUNT(DISTINCT message) as messageCount
RETURN person.id, person.firstName, person.lastName, threadCount, messageCount
ORDER BY messageCount DESC, person.id ASC
LIMIT 100;