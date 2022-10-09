FROM GRAPH snb.snbGraph
MATCH (message:Message)
LET year = get_year(datetime_from_unix_time_in_ms(message.creationDate)),
    isComment = NOT message.isPost,
    lengthCategory = CASE
        WHEN length(message.content) < 40  THEN 0
        WHEN length(message.content) < 80  THEN 1
        WHEN length(message.content) < 160 THEN 2
        ELSE 3
    END,
    totalMessages = ( FROM GRAPH snb.snbGraph
                      MATCH (inner_m:Message)
                      WHERE inner_m.creationDate < 1342803345373
                      AND inner_m.content IS NOT NULL
                      SELECT VALUE COUNT(inner_m) )[0]
WHERE     message.creationDate < 1342803345373 AND message.content IS NOT NULL
GROUP BY  year, isComment, lengthCategory, totalMessages
SELECT    year, isComment, lengthCategory,
    COUNT(*) AS messageCount,
    AVG(length(message.content)) AS averageMessageLength,
    SUM(length(message.content)) AS sumMessageLength,
    COUNT(*) * 100.0 / totalMessages AS percentageOfMessages
ORDER BY  year DESC, isComment ASC, lengthCategory ASC;