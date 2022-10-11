FROM  GRAPH snb.snbGraph
MATCH (person:Person)-[:KNOWS{2,2}]-(foaf:Person)-[:P_IS_LOCATED_IN]->(city:City)
LET   bd = get_month(datetime_from_unix_time_in_ms(foaf.birthday)),
  common = ( FROM GRAPH snb.snbGraph
             MATCH (person)-[:HAS_INTEREST]->(tag:Tag)<-[:M_HAS_TAG]-(post:Message)-[:HAS_CREATOR]->(foaf)
             WHERE post.isPost = true
             SELECT VALUE COUNT(DISTINCT post) )[0],
uncommon = ( FROM GRAPH snb.snbGraph
             MATCH (post:Message)-[:HAS_CREATOR]->(foaf)
             WHERE post.isPost = true AND
                NOT EXISTS ( FROM GRAPH snb.snbGraph
                             MATCH (person)-[:HAS_INTEREST]->(:Tag)<-[:M_HAS_TAG]-(post)
                             SELECT VALUE 1 )
             SELECT VALUE COUNT(DISTINCT post) )[0]          
WHERE person.id = 933 AND
    NOT EXISTS ( FROM GRAPH snb.snbGraph
                 MATCH (person)-[:KNOWS]-(foaf)
                 SELECT VALUE 1 ) AND
    ((bd.month = 3 AND bd.day >= 21) OR (bd.month = (3%12)+1 AND bd.day < 22))
SELECT
    foaf.id,
    foaf.firstName,
    foaf.lastName,
    common - uncommon AS commonInterestScore,
    foaf.gender,
    city.name
ORDER BY commonInterestScore DESC, foaf.id ASC
LIMIT    10;