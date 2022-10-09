FROM  GRAPH snb.snbGraph
MATCH (person:Person)-[knows:KNOWS]-(friend:Person)
WHERE person.id = 933
SELECT
    friend.id,
    friend.firstName,
    friend.lastName,
    knows.creationDate
ORDER BY knows.creationDate DESC, friend.id ASC;