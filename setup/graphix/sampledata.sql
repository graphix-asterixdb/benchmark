DROP DATAVERSE snb IF EXISTS;
CREATE DATAVERSE snb;
USE snb;


CREATE TYPE MessageType AS closed {
    id: bigint,
    imageFile: string?,
    creationDate: bigint,
    locationIP: string,
    browserUsed: string,
    language: string?,
    content: string?,
    length: int,
    creatorId: bigint,
    forumId: bigint?,
    placeId: bigint,
    replyOfMessageId: bigint?,
    isPost: boolean,
    tags: [bigint]
};


CREATE TYPE ForumType AS closed {
    id: bigint,
    title: string,
    creationDate: bigint,
    moderatorId: bigint,
    tags: [bigint]
};

CREATE TYPE ForumPersonType AS closed {
    forumId: bigint,
    personId: bigint,
    joinDate: bigint
};

CREATE TYPE UniversityType AS closed {
    id: bigint,
    name: string,
    url: string,
    placeId: bigint
};

CREATE TYPE UniversityYearType AS closed {
    organizationId: bigint,
    classYear: int
};

CREATE TYPE CompanyYearType AS closed {
    organizationId: bigint,
    workFrom: int
};

CREATE TYPE PersonType AS closed {
    id: bigint,
    firstName: string,
    lastName: string,
    gender: string,
    birthday: bigint,
    creationDate: bigint,
    locationIP: string,
    browserUsed: string,
    placeId: bigint,
    language: [string],
    email: [string],
    universities: [UniversityYearType],
    companies: [CompanyYearType]
};

CREATE TYPE PersonTagType AS closed {
    personId: bigint,
    tagId: bigint
};

CREATE TYPE KnowsType AS closed {
    startId: bigint,
    endId: bigint,
    creationDate: bigint
};

CREATE TYPE LikesType AS closed {
    personId: bigint,
    messageId: bigint,
    creationDate: bigint
};

CREATE TYPE LocationType AS closed {
    id: bigint,
    name: string,
    url: string,
    containerId: bigint?
};

CREATE TYPE TagClassType AS closed {
    id: bigint,
    name: string,
    url: string,
    isSubclassOf: bigint?
};

CREATE TYPE TagType AS closed {
    id: bigint,
    name: string,
    url: string,
    tagClassId: bigint
};

CREATE TYPE Knows19Type AS closed {
    person1id: bigint,
    person2id: bigint,
    weight: float
};

CREATE TYPE Knows20Type AS closed {
    person1id: bigint,
    person2id: bigint,
    weight: int
};

CREATE TYPE Knows14Type AS closed {
    person1id: bigint,
    person2id: bigint,
    weight: float
};

CREATE TYPE Knows15Type AS closed {
    person1id: bigint,
    person2id: bigint,
    weight: float
};

CREATE DATASET Messages (MessageType)        PRIMARY KEY id;
CREATE DATASET Forums (ForumType)            PRIMARY KEY id;
CREATE DATASET ForumPerson (ForumPersonType) PRIMARY KEY forumId, personId;
CREATE DATASET Universities (UniversityType) PRIMARY KEY id;
CREATE DATASET Companies (UniversityType)    PRIMARY KEY id;
CREATE DATASET Persons (PersonType)          PRIMARY KEY id;
CREATE DATASET PersonTag (PersonTagType)     PRIMARY KEY personId, tagId;
CREATE DATASET Knows (KnowsType)             PRIMARY KEY startId, endId;
CREATE DATASET Likes (LikesType)             PRIMARY KEY personId, messageId;
CREATE DATASET Cities (LocationType)         PRIMARY KEY id;
CREATE DATASET Countries (LocationType)      PRIMARY KEY id;
CREATE DATASET Continents (LocationType)     PRIMARY KEY id;
CREATE DATASET TagClasses (TagClassType)     PRIMARY KEY id;
CREATE DATASET Tags (TagType)                PRIMARY KEY id;
CREATE DATASET Knows19 (Knows19Type)         PRIMARY KEY person1id, person2id;
CREATE DATASET Knows20 (Knows20Type)         PRIMARY KEY person1id, person2id;
CREATE DATASET Knows14 (Knows14Type)         PRIMARY KEY person1id, person2id;
CREATE DATASET Knows15 (Knows15Type)         PRIMARY KEY person1id, person2id;


LOAD DATASET Messages     USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/messages.json"),("format"="json"));
LOAD DATASET Forums       USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/forums.json"),("format"="json"));
LOAD DATASET ForumPerson  USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/forumperson.json"),("format"="json"));
LOAD DATASET Universities USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/universities.json"),("format"="json"));
LOAD DATASET Companies    USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/companies.json"),("format"="json"));
LOAD DATASET Persons      USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/persons.json"),("format"="json"));
LOAD DATASET PersonTag    USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/persontag.json"),("format"="json"));
LOAD DATASET Knows        USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/knows.json"),("format"="json"));
LOAD DATASET Likes        USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/likes.json"),("format"="json"));
LOAD DATASET Cities       USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/cities.json"),("format"="json"));
LOAD DATASET Countries    USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/countries.json"),("format"="json"));
LOAD DATASET Continents   USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/continents.json"),("format"="json"));
LOAD DATASET TagClasses   USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/tagclasses.json"),("format"="json"));
LOAD DATASET Tags         USING localfs (("path"="127.0.0.1:///home/sushrut/datainput/tags.json"),("format"="json"));


CREATE GRAPH snbGraph AS

VERTEX (:Message)    PRIMARY KEY (id) AS Messages,
VERTEX (:Forum)      PRIMARY KEY (id) AS Forums,
VERTEX (:Person)     PRIMARY KEY (id) AS Persons,
VERTEX (:Tag)        PRIMARY KEY (id) AS Tags,
VERTEX (:TagClass)   PRIMARY KEY (id) AS TagClasses,
VERTEX (:University) PRIMARY KEY (id) AS Universities,
VERTEX (:Company)    PRIMARY KEY (id) AS Companies,
VERTEX (:City)       PRIMARY KEY (id) AS Cities,
VERTEX (:Country)    PRIMARY KEY (id) AS Countries,
VERTEX (:Continent)  PRIMARY KEY (id) AS Continents,

EDGE (:Message)-[:REPLY_OF]->(:Message)
SOURCE KEY (id) DESTINATION KEY (replyOfMessageId)
AS ( SELECT id, replyOfMessageId FROM Messages WHERE isPost = false ),

EDGE (:Message)-[:HAS_CREATOR]->(:Person)
SOURCE KEY (id) DESTINATION KEY (creatorId)
AS ( SELECT id, creatorId FROM Messages ),

EDGE (:Message)-[:M_IS_LOCATED_IN]->(:Country)
SOURCE KEY (id) DESTINATION KEY (placeId)
AS ( SELECT id, placeId FROM Messages ),

EDGE (:Message)-[:M_HAS_TAG]->(:Tag)
SOURCE KEY (id) DESTINATION KEY (tagId)
AS ( SELECT M.id, tagId FROM Messages M UNNEST M.tags tagId ),

EDGE (:Forum)-[:CONTAINER_OF]->(:Message)
SOURCE KEY (forumId) DESTINATION KEY (id)
AS ( SELECT id, forumId FROM Messages WHERE isPost = true ),

EDGE (:Forum)-[:HAS_MODERATOR]->(:Person)
SOURCE KEY (id) DESTINATION KEY (moderatorId)
AS ( SELECT id, moderatorId FROM Forums ),

EDGE (:Forum)-[:HAS_MEMBER]->(:Person)
SOURCE KEY (forumId) DESTINATION KEY (personId)
AS ( SELECT forumId, personId, joinDate FROM ForumPerson ),

EDGE (:Forum)-[:F_HAS_TAG]->(:Tag)
SOURCE KEY (id) DESTINATION KEY (tagId)
AS ( SELECT F.id, tagId FROM Forums F UNNEST F.tags tagId ),

EDGE (:Person)-[:KNOWS]->(:Person)
SOURCE KEY (startId) DESTINATION KEY (endId)
AS ( SELECT startId, endId, creationDate FROM Knows ),

EDGE (:Person)-[:HAS_INTEREST]->(:Tag)
SOURCE KEY (personId) DESTINATION KEY (tagId)
AS ( SELECT personId, tagId FROM PersonTag ),

EDGE (:Person)-[:P_IS_LOCATED_IN]->(:City)
SOURCE KEY (id) DESTINATION KEY (placeId)
AS ( SELECT id, placeId FROM Persons ),

EDGE (:Person)-[:STUDY_AT]->(:University)
SOURCE KEY (id) DESTINATION KEY (organizationId)
AS ( SELECT P.id, U.organizationId, U.classYear FROM Persons P UNNEST P.universities U ),

EDGE (:Person)-[:WORK_AT]->(:Company)
SOURCE KEY (id) DESTINATION KEY (organizationId)
AS ( SELECT P.id, C.organizationId, C.workFrom FROM Persons P UNNEST P.companies C ),

EDGE (:Person)-[:LIKES]->(:Message)
SOURCE KEY (personId) DESTINATION KEY (messageId)
AS ( SELECT personId, messageId, creationDate FROM Likes ),

EDGE (:Tag)-[:HAS_TYPE]->(:TagClass)
SOURCE KEY (id) DESTINATION KEY (tagClassId)
AS ( SELECT id, tagClassId FROM Tags ),

EDGE (:TagClass)-[:IS_SUBCLASS_OF]->(:TagClass)
SOURCE KEY (id) DESTINATION KEY (isSubclassOf)
AS ( SELECT id, isSubclassOf FROM TagClasses ),

EDGE (:University)-[:U_IS_LOCATED_IN]->(:City)
SOURCE KEY (id) DESTINATION KEY (placeId)
AS ( SELECT id, placeId FROM Universities ),

EDGE (:Company)-[:C_IS_LOCATED_IN]->(:Country)
SOURCE KEY (id) DESTINATION KEY (placeId)
AS ( SELECT id, placeId FROM Companies ),

EDGE (:City)-[:IS_PART_OF]->(:Country)
SOURCE KEY (id) DESTINATION KEY (containerId)
AS ( SELECT id, containerId FROM Cities ),

EDGE (:Country)-[:IS_PART_OF]->(:Continent)
SOURCE KEY (id) DESTINATION KEY (containerId)
AS ( SELECT id, containerId FROM Countries ),

EDGE (:Person)-[:KNOWS19]->(:Person)
SOURCE KEY (person1id) DESTINATION KEY (person2id)
AS ( SELECT person1id, person2id, weight FROM Knows19 ),

EDGE (:Person)-[:KNOWS20]->(:Person)
SOURCE KEY (person1id) DESTINATION KEY (person2id)
AS ( SELECT person1id, person2id, weight FROM Knows20 ),

EDGE (:Person)-[:KNOWS14]->(:Person)
SOURCE KEY (person1id) DESTINATION KEY (person2id)
AS ( SELECT person1id, person2id, weight FROM Knows14 ),

EDGE (:Person)-[:KNOWS15]->(:Person)
SOURCE KEY (person1id) DESTINATION KEY (person2id)
AS ( SELECT person1id, person2id, weight FROM Knows15 );
