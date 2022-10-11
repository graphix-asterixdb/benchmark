// :param tagClass: Politician
// :param country: Russia

MATCH (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(person:Person)<-[:HAS_MODERATOR]-(forum:Forum),
      (forum)-[:CONTAINER_OF]->(:Post)<-[:REPLY_OF*0..]-(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagClass:TagClass)
WHERE country.name = $country AND tagClass.name = $tagClass
WITH forum, person, COUNT(DISTINCT message) AS messageCount
RETURN forum.id, forum.title, forum.creationDate, person.id, messageCount
ORDER BY messageCount DESC, forum.id ASC
LIMIT 20;