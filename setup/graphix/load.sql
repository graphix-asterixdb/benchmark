DROP DATAVERSE snb IF EXISTS;
CREATE DATAVERSE snb;
USE snb;

CREATE TYPE PostType AS closed {
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
    placeId: bigint
};

CREATE TYPE CommentType AS closed {
    id: bigint,
    creationDate: bigint,
    locationIP: string,
    browserUsed: string,
    content: string?,
    length: int,
    creatorId: bigint,
    placeId: bigint,
    replyOfPostId: bigint?,
    replyOfCommentId: bigint?
};

CREATE TYPE MessageType_ AS closed {
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
    isPost: boolean
};

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

CREATE TYPE ForumType_ AS closed {
    id: bigint,
    title: string,
    creationDate: bigint,
    moderatorId: bigint
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

CREATE TYPE ForumTagType AS closed {
    forumId: bigint,
    tagId: bigint
};

CREATE TYPE OrganizationType AS closed {
    id: bigint,
    otype: string,
    name: string,
    url: string,
    placeId: bigint
};

CREATE TYPE UniversityType AS closed {
    id: bigint,
    name: string,
    url: string,
    placeId: bigint
};

CREATE TYPE PersonType_ AS closed {
    id: bigint,
    firstName: string,
    lastName: string,
    gender: string,
    birthday: bigint,
    creationDate: bigint,
    locationIP: string,
    browserUsed: string,
    placeId: bigint,
    language: string,
    email: string
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

CREATE TYPE PersonUniversityType AS closed {
    personId: bigint,
    organizationId: bigint,
    classYear: int
};

CREATE TYPE PersonCompanyType AS closed {
    personId: bigint,
    organizationId: bigint,
    workFrom: int
};

CREATE TYPE PlaceType AS closed {
    id: bigint,
    name: string,
    url: string,
    ptype: string,
    containerId: bigint?
};

CREATE TYPE LocationType AS closed {
    id: bigint,
    name: string,
    url: string,
    containerId: bigint?
};

CREATE TYPE MessageTagType AS closed {
    messageId: bigint,
    tagId: bigint
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

CREATE DATASET Posts (PostType) PRIMARY KEY id;
CREATE DATASET Comments (CommentType) PRIMARY KEY id;
CREATE DATASET Messages_ (MessageType_) PRIMARY KEY id;
CREATE DATASET Messages (MessageType) PRIMARY KEY id;
CREATE DATASET Forums (ForumType) PRIMARY KEY id;
CREATE DATASET Forums_ (ForumType_) PRIMARY KEY id;
CREATE DATASET ForumPerson (ForumPersonType) PRIMARY KEY forumId, personId;
CREATE DATASET ForumTag (ForumTagType) PRIMARY KEY forumId, tagId;
CREATE DATASET Organizations (OrganizationType) PRIMARY KEY id;
CREATE DATASET Universities (UniversityType) PRIMARY KEY id;
CREATE DATASET Companies (UniversityType) PRIMARY KEY id;
CREATE DATASET Persons_ (PersonType_) PRIMARY KEY id;
CREATE DATASET Persons (PersonType) PRIMARY KEY id;
CREATE DATASET PersonTag (PersonTagType) PRIMARY KEY personId, tagId;
CREATE DATASET Knows (KnowsType) PRIMARY KEY startId, endId;
CREATE DATASET Likes (LikesType) PRIMARY KEY personId, messageId;
CREATE DATASET LikesComment (LikesType) PRIMARY KEY personId, messageId;
CREATE DATASET LikesPost (LikesType) PRIMARY KEY personId, messageId;
CREATE DATASET PersonUniversity (PersonUniversityType) PRIMARY KEY personId, organizationId;
CREATE DATASET PersonCompany (PersonCompanyType) PRIMARY KEY personId, organizationId;
CREATE DATASET Places (PlaceType) PRIMARY KEY id;
CREATE DATASET Cities (LocationType) PRIMARY KEY id;
CREATE DATASET Countries (LocationType) PRIMARY KEY id;
CREATE DATASET Continents (LocationType) PRIMARY KEY id;
CREATE DATASET MessageTag (MessageTagType) PRIMARY KEY messageId, tagId;
CREATE DATASET CommentTag (MessageTagType) PRIMARY KEY messageId, tagId;
CREATE DATASET PostTag (MessageTagType) PRIMARY KEY messageId, tagId;
CREATE DATASET TagClasses (TagClassType) PRIMARY KEY id;
CREATE DATASET Tags (TagType) PRIMARY KEY id;
CREATE DATASET Knows19 (Knows19Type) PRIMARY KEY person1id, person2id;
CREATE DATASET Knows20 (Knows20Type) PRIMARY KEY person1id, person2id;
CREATE DATASET Knows14 (Knows14Type) PRIMARY KEY person1id, person2id;
CREATE DATASET Knows15 (Knows15Type) PRIMARY KEY person1id, person2id;


LOAD DATASET Posts USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/post_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));
 
LOAD DATASET Comments USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/comment_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET Forums_ USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/forum_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET ForumPerson USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/forum_hasMember_person_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET ForumTag USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/forum_hasTag_tag_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET Organizations USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/static/organisation_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET Persons_ USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET PersonTag USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_hasInterest_tag_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET Knows USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_knows_person_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET LikesComment USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_likes_comment_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET LikesPost USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_likes_post_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET PersonUniversity USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_studyAt_organisation_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET PersonCompany USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/person_workAt_organisation_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET Places USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/static/place_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET CommentTag USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/comment_hasTag_tag_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET PostTag USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/dynamic/post_hasTag_tag_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET TagClasses USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/static/tagclass_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));

LOAD DATASET Tags USING localfs
(("path"="127.0.0.1:///home/sushrut/data_input/static/tag_0_0.csv"),
("format"="delimited-text"),("delimiter"="|"),("null"=""),("header"="true"));


INSERT INTO Messages_ (SELECT P.*, true AS isPost FROM Posts P);
INSERT INTO Messages_ (SELECT C.id, C.creationDate, C.locationIP, C.browserUsed, C.content, C.length, C.creatorId, C.placeId,
                      false AS isPost, coalesce(C.replyOfPostId, C.replyOfCommentId) AS replyOfMessageId FROM Comments C);

INSERT INTO Likes (SELECT VALUE P FROM LikesPost P);
INSERT INTO Likes (SELECT VALUE C FROM LikesComment C);

INSERT INTO MessageTag (SELECT VALUE P FROM PostTag P);
INSERT INTO MessageTag (SELECT VALUE C FROM CommentTag C);

INSERT INTO Messages (SELECT M.*, (SELECT VALUE T.tagId FROM MessageTag T WHERE M.id = T.messageId) AS tags FROM Messages_ M);
INSERT INTO Forums (SELECT F.*, (SELECT VALUE T.tagId FROM ForumTag T WHERE F.id = T.forumId) AS tags FROM Forums_ F);


INSERT INTO Persons
    (SELECT P.*, split(language, ';') AS language, split(email, ';') AS email,
       (SELECT U.organizationId, U.classYear FROM PersonUniversity U WHERE P.id = U.personId) AS universities,
       (SELECT C.organizationId, C.workFrom FROM PersonCompany C WHERE P.id = C.personId) AS companies
     FROM Persons_ P);

INSERT INTO Cities (SELECT P.id, P.name, P.url, P.containerId FROM Places P WHERE P.ptype = 'city');
INSERT INTO Countries (SELECT P.id, P.name, P.url, P.containerId FROM Places P WHERE P.ptype = 'country');
INSERT INTO Continents (SELECT P.id, P.name, P.url FROM Places P WHERE P.ptype = 'continent');

INSERT INTO Universities (SELECT O.id, O.name, O.url, O.placeId FROM Organizations O WHERE O.otype = 'university');
INSERT INTO Companies (SELECT O.id, O.name, O.url, O.placeId FROM Organizations O WHERE O.otype = 'company');

DROP DATASET Posts;
DROP DATASET Comments;
DROP DATASET LikesPost;
DROP DATASET LikesComment;
DROP DATASET PostTag;
DROP DATASET CommentTag;
DROP DATASET Persons_;
DROP DATASET Messages_;
DROP DATASET Forums_;
DROP DATASET MessageTag;
DROP DATASET ForumTag;
DROP DATASET PersonCompany;
DROP DATASET PersonUniversity;
DROP DATASET Places;
DROP DATASET Organizations;


DROP GRAPH snbGraph IF EXISTS;

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
