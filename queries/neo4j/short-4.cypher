MATCH  (message:Message)
WHERE  message.id = $messageId
RETURN message.creationDate AS messageCreationDate,
       COALESCE(message.content, message.imageFile) AS messageContent;
