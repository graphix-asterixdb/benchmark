MATCH    (person:Person)-[:KNOWS*1..2]-(otherPerson:Person)<-[:HAS_CREATOR]-(message:Message)
WHERE    person.id = $personId AND
         message.creationDate < $maxDate AND
         person <> otherPerson
WITH     DISTINCT otherPerson,
                  message
RETURN   otherPerson.id,
         otherPerson.firstName,
         otherPerson.lastName,
         message.id,
         COALESCE(message.content, message.imageFile),
         message.creationDate
ORDER BY message.creationDate DESC,
         message.id ASC
LIMIT    $limit;
