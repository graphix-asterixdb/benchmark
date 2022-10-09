FROM   GRAPH snb.snbGraph
MATCH  (message:Message)
WHERE  message.id = 618475290625
SELECT 
    message.creationDate AS messageCreationDate,
    coalesce(message.content, message.imageFile) AS messageContent;