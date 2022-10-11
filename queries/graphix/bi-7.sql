FROM     GRAPH snb.snbGraph
MATCH    (tag:Tag)<-[:M_HAS_TAG]-(:Message)<-[:REPLY_OF]-(comment:Message)-[:M_HAS_TAG]->(relatedTag:Tag)
WHERE    tag.name = 'Abbas_I_of_Persia' AND comment.isPost = false AND
         NOT EXISTS ( FROM GRAPH snb.snbGraph
                      MATCH (comment)-[:M_HAS_TAG]->(tag)
                      SELECT VALUE 1 )
GROUP BY relatedTag
SELECT   relatedTag.name, COUNT(comment) AS commentCount
ORDER BY commentCount DESC, relatedTag.name ASC
LIMIT    100;