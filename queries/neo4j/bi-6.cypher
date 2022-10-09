// :param tag: Abbas_I_of_Persia

MATCH (tag:Tag)<-[:HAS_TAG]-(message1:Message)-[:HAS_CREATOR]->(person1:Person)
WHERE tag.name = $tag
OPTIONAL MATCH (message1)<-[:LIKES]-(person2:Person)<-[:HAS_CREATOR]-(message2:Message)
OPTIONAL MATCH (message2)<-[:LIKES]-(person3:Person)
WITH person1, person2, COUNT(person3) as popularityScore
WITH person1, SUM(popularityScore) AS authorityScore
RETURN person1.id, authorityScore
ORDER BY authorityScore DESC, person1.id ASC
LIMIT 100;