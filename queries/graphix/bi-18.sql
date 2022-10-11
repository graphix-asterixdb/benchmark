FROM     GRAPH snb.snbGraph
MATCH    (tag:Tag)<-[:HAS_INTEREST]-(person1:Person)-[:KNOWS]-(mutualFriend:Person)-[:KNOWS]-(person2:Person)-[:HAS_INTEREST]->(tag)
WHERE    tag.name = 'Frank_Sinatra'
  AND    NOT EXISTS ( FROM GRAPH snb.snbGraph
                      MATCH (person1)-[:KNOWS]-(person2)
                      SELECT VALUE 1 )
GROUP BY person1, person2                   
SELECT   person1.id AS person1Id, person2.id AS person2Id, COUNT(DISTINCT mutualFriend) AS mutualFriendCount
ORDER BY mutualFriendCount DESC, person1Id ASC, person2Id ASC
LIMIT    20;

// temporary fix:

FROM     GRAPH snb.snbGraph
MATCH    (tag:Tag)<-[:HAS_INTEREST]-(person1:Person)-[:KNOWS]-(mutualFriend:Person)-[:KNOWS]-(person2:Person)-[:HAS_INTEREST]->(tag)
WHERE    tag.name = 'Frank_Sinatra'
  AND    NOT EXISTS ( FROM GRAPH snb.snbGraph
                      MATCH (person1)-[:KNOWS]->(person2)
                      SELECT VALUE 1 )
  AND    NOT EXISTS ( FROM GRAPH snb.snbGraph
                      MATCH (person1)<-[:KNOWS]-(person2)
                      SELECT VALUE 1 )                   
GROUP BY person1, person2                   
SELECT   person1.id AS person1Id, person2.id AS person2Id, COUNT(DISTINCT mutualFriend) AS mutualFriendCount
ORDER BY mutualFriendCount DESC, person1Id ASC, person2Id ASC
LIMIT    20;