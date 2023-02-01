MATCH          (tag:Tag {name: $tag})
OPTIONAL MATCH (tag)<-[interest:HAS_INTEREST]-(person:Person)
WITH           tag,
               COLLECT(person) AS interestedPersons
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person:Person)
WHERE          $startDate < message.creationDate AND
               message.creationDate < $endDate
WITH           tag,
               interestedPersons + collect(person) AS persons
UNWIND         persons AS person
WITH           DISTINCT tag,
                        person
WITH           tag,
               person,
               100 * SIZE([(tag)<-[interest:HAS_INTEREST]-(person) | interest]) +
                     SIZE([(tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person)
                           WHERE $startDate < message.creationDate AND
                                 message.creationDate < $endDate | message]) AS score
OPTIONAL MATCH (person)-[:KNOWS]-(friend)
WITH           person,
               score,
               100 * SIZE([(tag)<-[interest:HAS_INTEREST]-(friend) | interest]) +
                     SIZE([(tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(friend)
                           WHERE $startDate < message.creationDate AND
                                 message.creationDate < $endDate | message]) AS friendScore
RETURN         person.id,
               score,
               SUM(friendScore) AS friendsScore
ORDER BY       score + friendsScore DESC,
               person.id ASC
LIMIT          $limit;
