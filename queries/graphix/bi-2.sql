FROM GRAPH snb.snbGraph
MATCH (tagClass:TagClass)<-[:HAS_TYPE]-(tag:Tag)
LET countWindow1 = ( FROM GRAPH snb.snbGraph
                     MATCH (tag)<-[:M_HAS_TAG]-(m1:Message)
                     WHERE 1313579421570 <= m1.creationDate AND m1.creationDate < 1313579421570 + 8640000000
                     SELECT VALUE COUNT(m1) )[0], 
    countWindow2 = ( FROM GRAPH snb.snbGraph
                     MATCH (tag)<-[:M_HAS_TAG]-(m2:Message)
                     WHERE 1313579421570 + 8640000000 <= m2.creationDate AND m2.creationDate < 1313579421570 + 17280000000
                     SELECT VALUE COUNT(m2) )[0]
WHERE tagClass.name = 'Politician'
SELECT tag.name AS tagName, countWindow1, countWindow2, abs(countWindow1 - countWindow2) as diff
ORDER BY diff DESC, tagName ASC
LIMIT 100;