// :param personId: 933
// :param tagClassName: 'Monarch'

MATCH (person:Person)-[:KNOWS]-(friend:Person)<-[:HAS_CREATOR]-(comment:Comment)-[:REPLY_OF]->(post:Post),
      (post)-[:HAS_TAG]->(tag:Tag)-[:HAS_TYPE]->(:TagClass)-[:IS_SUBCLASS_OF*0..]->(tagClass:TagClass)
WHERE person.id = $personId AND tagClass.name = $tagClassName
WITH friend, COLLECT(DISTINCT tag.name) AS tagNames, COUNT(DISTINCT comment) as replyCount
RETURN 
    friend.id,
    friend.firstName,
    friend.lastName,
    tagNames,
    replyCount    
ORDER BY replyCount DESC, friend.id ASC
LIMIT 20;