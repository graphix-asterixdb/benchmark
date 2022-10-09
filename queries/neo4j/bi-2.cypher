// :param date: 1313579421570
// :param tagClass: Politician

MATCH (tagClass:TagClass)<-[:HAS_TYPE]-(tag:Tag)
WHERE tagClass.name = $tagClass
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(m1:Message)
WHERE $date <= m1.creationDate AND m1.creationDate < $date + 8640000000
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(m2:Message)
WHERE $date + 8640000000 <= m2.creationDate AND m2.creationDate < $date + 17280000000
WITH tag.name AS tagName, COUNT(DISTINCT m1) AS countWindow1, COUNT(DISTINCT m2) AS countWindow2
RETURN tagName, countWindow1, countWindow2, abs(countWindow1 - countWindow2) as diff
ORDER BY diff DESC, tagName ASC
LIMIT 100;