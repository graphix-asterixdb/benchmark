SET       `graphix.semantics.pattern` "edge-isomorphism";

WITH zombies AS 
( FROM         GRAPH snb.snbGraph
  MATCH        (country:Country)<-[:IS_PART_OF]-(:City)<-[:P_IS_LOCATED_IN]-(zombie:Person)
  LEFT MATCH   (zombie)<-[:HAS_CREATOR]-(message:Message)
  LET months = 12 * (get_year(datetime_from_unix_time_in_ms(1357002061000))  - get_year(datetime_from_unix_time_in_ms(zombie.creationDate)))
                  + (get_month(datetime_from_unix_time_in_ms(1357002061000)) - get_month(datetime_from_unix_time_in_ms(zombie.creationDate))) + 1
  WHERE        zombie.creationDate < 1357002061000 AND country.name = 'China'
    AND        (message IS UNKNOWN OR message.creationDate < 1357002061000)
  GROUP BY     zombie, months
  HAVING       COUNT(message) / months < 1
  SELECT VALUE zombie.id )
  
FROM   GRAPH snb.snbGraph
MATCH  (zombie:Person)
LET zombieLikeCount = ( FROM GRAPH snb.snbGraph
                        MATCH (izombie:Person)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerZombie:Person)
                        WHERE izombie = zombie AND likerZombie.id IN zombies AND likerZombie.creationDate < 1357002061000
                        SELECT VALUE COUNT (likerZombie) )[0],
    totalLikeCount  = ( FROM GRAPH snb.snbGraph
                        MATCH (izombie:Person)<-[:HAS_CREATOR]-(message:Message)<-[:LIKES]-(likerPerson:Person)
                        WHERE izombie = zombie AND likerPerson.creationDate < 1357002061000
                        SELECT VALUE COUNT (likerPerson) )[0]
WHERE    zombie.id IN zombies
SELECT   zombie.id, zombieLikeCount, totalLikeCount,
  CASE   totalLikeCount
    WHEN 0 THEN 0.0
    ELSE zombieLikeCount / totalLikeCount
  END AS zombieScore
ORDER BY
  zombieScore DESC,
  zombie.id ASC
LIMIT    100;