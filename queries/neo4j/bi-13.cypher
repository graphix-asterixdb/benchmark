// :param endDate => 1357002061000
// :param country: 'China'

MATCH (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(zombie:Person)
WHERE zombie.creationDate < $endDate AND country.name = $country
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)
WHERE message.creationDate < $endDate
WITH zombie, COUNT(message) AS messageCount,
    12 * (datetime({epochmillis: $endDate}).year  - datetime({epochmillis: zombie.creationDate}).year ) 
    + (datetime({epochmillis: $endDate}).month - datetime({epochmillis: zombie.creationDate}).month)
    + 1 AS months
WHERE messageCount / months < 1
WITH collect(zombie) AS zombies
UNWIND zombies AS zombie
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerZombie:Person)
WHERE likerZombie IN zombies AND likerZombie.creationDate < $endDate
WITH zombie, COUNT(likerZombie) AS zombieLikeCount
OPTIONAL MATCH (zombie)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerPerson:Person)
WHERE likerPerson.creationDate < $endDate
WITH zombie, zombieLikeCount, COUNT(likerPerson) AS totalLikeCount
RETURN zombie.id, zombieLikeCount, totalLikeCount,
  CASE totalLikeCount
    WHEN 0 THEN 0.0
    ELSE zombieLikeCount / toFloat(totalLikeCount)
  END AS zombieScore
ORDER BY
  zombieScore DESC,
  zombie.id ASC
LIMIT 100