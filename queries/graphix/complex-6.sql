FROM     GRAPH snb.snbGraph
MATCH    (person:Person)-[:KNOWS{1,2}]-(otherPerson:Person)<-[:HAS_CREATOR]-(post:Message),
         (tag:Tag)<-[:M_HAS_TAG]-(post)-[:M_HAS_TAG]->(otherTag:Tag)
WHERE    person.id = 933 AND tag.name = 'Sammy_Sosa' AND otherTag.name != 'Sammy_Sosa' AND post.isPost = true
GROUP BY otherTag
SELECT   otherTag.name AS otherTagName, COUNT(DISTINCT post) AS postCount
ORDER BY postCount DESC, otherTagName ASC
LIMIT    10;