// :param personId: 933

MATCH (person:Person)-[knows:KNOWS]-(friend:Person)
WHERE person.id = $personId
RETURN
    friend.id,
    friend.firstName,
    friend.lastName,
    knows.creationDate
ORDER BY knows.creationDate DESC, friend.id ASC;