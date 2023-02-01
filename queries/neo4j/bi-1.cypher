MATCH    (message:Message)
WHERE    message.creationDate < $datetime AND
         message.content IS NOT NULL
WITH     COUNT(message) as totalMessages
MATCH    (message:Message)
WHERE    message.creationDate < $datetime AND
         message.content IS NOT NULL
RETURN   datetime({epochmillis: message.creationDate}).year AS year,
         (message:Comment) AS isComment,
         CASE WHEN SIZE(message.content) < 40
              THEN 0
              WHEN SIZE(message.content) < 80
              THEN 1
              WHEN SIZE(message.content) < 160
              THEN 2
              ELSE 3
         END AS lengthCategory,
         COUNT(*) AS messageCount,
         AVG(size(message.content)) AS averageMessageLength,
         SUM(size(message.content)) AS sumMessageLength,
         COUNT(*) * 100.0 / totalMessages AS percentageOfMessages
ORDER BY year DESC,
         isComment ASC,
         lengthCategory ASC;
