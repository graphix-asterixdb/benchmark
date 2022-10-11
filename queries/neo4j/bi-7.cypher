// :param tag: Abbas_I_of_Persia

MATCH (tag:Tag)<-[:HAS_TAG]-(:Message)<-[:REPLY_OF]-(comment:Comment)-[:HAS_TAG]->(relatedTag:Tag)
WHERE tag.name = $tag AND relatedTag.name <> $tag AND NOT exists((comment)-[:HAS_TAG]->(tag))
RETURN relatedTag.name, COUNT(comment) as count
ORDER BY count DESC, relatedTag.name ASC
LIMIT 100;