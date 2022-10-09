// :param date: 1313579421570

MATCH (country:Country)<-[:IS_PART_OF]-(city:City)<-[:IS_LOCATED_IN]-(member:Person)<-[:HAS_MEMBER]-(forum:Forum)
WHERE forum.creationDate > $date
WITH forum, country, COUNT(member) as memberCount
WITH forum, MAX(memberCount) as memberCount
ORDER BY memberCount DESC
LIMIT 100
WITH COLLECT(forum) as topForums
MATCH (forum1:Forum), (person:Person)<-[:HAS_MEMBER]-(forum2:Forum)
WHERE forum1 IN topForums AND forum2 IN topForums
OPTIONAL MATCH (forum1)-[:CONTAINER_OF]->(:Post)<-[:REPLY_OF*0..]-(message:Message)-[:HAS_CREATOR]->(person)
WITH person, COUNT(DISTINCT message) AS messageCount
RETURN person.id, person.firstName, person.lastName, person.creationDate, messageCount
ORDER BY messageCount DESC, person.id ASC
LIMIT 100;