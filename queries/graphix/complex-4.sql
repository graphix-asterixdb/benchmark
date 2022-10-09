FROM   GRAPH snb.snbGraph
MATCH  (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(post:Message)-[:M_HAS_TAG]->(tag:Tag),
       (person)-[:KNOWS]-(:Person)<-[:HAS_CREATOR]-(post2:Message)
WHERE
    person.id = 933 AND post.isPost = true AND post2.isPost = true
    AND 1313579421570 <= post.creationDate AND post.creationDate < 1313579421570 + 365 * 86400000
    AND post2.creationDate < 1313579421570 AND
    NOT EXISTS ( FROM GRAPH snb.snbGraph 
                 MATCH (post2)-[:M_HAS_TAG]->(tag)
                 SELECT VALUE 1 )
GROUP BY  tag
SELECT    tag.name, COUNT(DISTINCT post) as postCount
ORDER BY  postCount DESC, tag.name ASC
LIMIT     10;