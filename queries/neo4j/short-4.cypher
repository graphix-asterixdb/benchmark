// :param messageId: 618475290625

MATCH (message:Message)
WHERE message.id = $messageId
RETURN 
    message.creationDate AS messageCreationDate,
    coalesce(message.content, message.imageFile) AS messageContent;