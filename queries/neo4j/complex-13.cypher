// :param person1Id: 933
// :param person2Id: 102

MATCH path = shortestPath((person1:Person)-[:KNOWS*]-(person2:Person))
WHERE person1.id = $person1Id AND person2.id = $person2Id
RETURN
    CASE
        WHEN path IS NULL THEN -1
        ELSE LENGTH(path)
    END AS shortestPathLength;