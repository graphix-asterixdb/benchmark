SET `compiler.groupmemory` "8MB";
SET `compiler.sortmemory` "8MB";
SET `compiler.joinmemory` "8MB";

FROM      GRAPH snb.snbGraph
MATCH     (person:Person)-[p:KNOWS{1,3}]-(otherPerson:Person)-[:P_IS_LOCATED_IN]->(locationCity:City)
LET companies = ( FROM GRAPH snb.snbGraph
                  MATCH (otherPerson)-[w:WORK_AT]->(company:Company)-[:C_IS_LOCATED_IN]->(companyCountry:Country)
                  SELECT company.name AS companyName, w.workFrom, companyCountry.name AS countryName),
 universities = ( FROM GRAPH snb.snbGraph
                  MATCH (otherPerson)-[s:STUDY_AT]->(university:University)-[:U_IS_LOCATED_IN]->(universityCity:City)
                  SELECT university.name AS universityName, s.classYear, universityCity.name AS cityName)
WHERE     person.id = 933 AND otherPerson.firstName = 'Jack'
GROUP BY  otherPerson, locationCity, companies, universities
SELECT
    otherPerson.id,
    otherPerson.lastName,
    MIN(PATH_HOP_COUNT(p)) AS distanceFromPerson,
    otherPerson.birthday,
    otherPerson.creationDate,
    otherPerson.gender,
    otherPerson.browserUsed,
    otherPerson.locationIP,
    otherPerson.email,
    otherPerson.speaks,
    locationCity.name,
    universities,
    companies
ORDER BY  distanceFromPerson ASC, otherPerson.lastName ASC, otherPerson.id ASC
LIMIT     20;
