// :param personId: 933
// :param startDate: 1313579421570
// :param durationDays: 365

MATCH (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(post:Post)-[:HAS_TAG]->(tag:Tag),
      (person)-[:KNOWS]-(:Person)<-[:HAS_CREATOR]-(post2:Post)
WHERE
    person.id = $personId 
    AND $startDate <= post.creationDate AND post.creationDate < $startDate + $durationDays * 86400000
    AND post2.creationDate < $startDate AND NOT exists((post2)-[:HAS_TAG]->(tag))
WITH tag, COUNT(DISTINCT post) AS postCount
RETURN tag.name, postCount
ORDER BY postCount DESC, tag.name ASC
LIMIT 10;