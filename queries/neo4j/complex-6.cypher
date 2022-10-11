// :param personId: 933
// :param tagName: 'Sammy_Sosa'

MATCH (person:Person)-[:KNOWS*1..2]-(otherPerson:Person)<-[:HAS_CREATOR]-(post:Post),
      (tag:Tag)<-[:HAS_TAG]-(post)-[:HAS_TAG]->(otherTag:Tag)
WHERE person.id = $personId AND tag.name = $tagName AND otherTag.name <> $tagName
WITH otherTag.name as otherTagName, COUNT(DISTINCT post) AS postCount
RETURN otherTagName, postCount
ORDER BY postCount DESC, otherTagName ASC
LIMIT 10;