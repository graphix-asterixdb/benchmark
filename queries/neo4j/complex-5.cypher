MATCH   (person:Person)-[:KNOWS*1..2]-(otherPerson:Person)<-[h:HAS_MEMBER]-(forum:Forum)-[:CONTAINER_OF]->(post:Post)
WHERE    person.id = $personId AND
         h.joinDate > $minDate AND
         EXISTS((post)-[:HAS_CREATOR]->(otherPerson))
WITH     forum,
         COUNT(DISTINCT post) AS postCount
RETURN   forum.title,
         postCount
ORDER BY postCount DESC,
         forum.id ASC
LIMIT    $limit;
