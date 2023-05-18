#!/bin/bash
set -eu
set -o pipefail

# This script is modified from:
# https://github.com/ldbc/ldbc_snb_bi/blob/main/cypher/scripts/import.sh
# ...for use with this benchmark.

cd "$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" >/dev/null 2>&1 && pwd )"

if [[ -z "${NEO4J_CONTAINER_ROOT}" ]]; then
  echo "Environment variable NEO4J_CONTAINER_ROOT must be set!"
  exit 1
elif [[ -z "${NEO4J_CSV_DIR}" ]]; then
  echo "Environment variable NEO4J_CSV_DIR must be set!"
  exit 1
fi

# A couple of variables... :-)
NEO4J_DATA_DIR=${NEO4J_CONTAINER_ROOT}/data
NEO4J_HEADER_DIR=`pwd`/headers

# Build our Neo4J directories.
mkdir -p ${NEO4J_CONTAINER_ROOT}/plugins
mkdir -p ${NEO4J_CONTAINER_ROOT}/../logs
mkdir -p ${NEO4J_DATA_DIR}
rm -rf ${NEO4J_DATA_DIR}/*

# Finally, run our import command.
NEO4J_PART_FIND_PATTERN="part-*.csv*"
NEO4J_HEADER_EXTENSION=".csv"
neo4j-admin database import full \
    --id-type=INTEGER \
    --ignore-empty-strings=true \
    --bad-tolerance=0 \
    --nodes=Place="${NEO4J_HEADER_DIR}/static/Place${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/Place -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/Place/%f')" \
    --nodes=Organisation="${NEO4J_HEADER_DIR}/static/Organisation${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/Organisation -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/Organisation/%f')" \
    --nodes=TagClass="${NEO4J_HEADER_DIR}/static/TagClass${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/TagClass -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/TagClass/%f')" \
    --nodes=Tag="${NEO4J_HEADER_DIR}/static/Tag${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/Tag -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/Tag/%f')" \
    --nodes=Forum="${NEO4J_HEADER_DIR}/dynamic/Forum${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Forum -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Forum/%f')" \
    --nodes=Person="${NEO4J_HEADER_DIR}/dynamic/Person${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person/%f')" \
    --nodes=Message:Comment="${NEO4J_HEADER_DIR}/dynamic/Comment${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Comment -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Comment/%f')" \
    --nodes=Message:Post="${NEO4J_HEADER_DIR}/dynamic/Post${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Post -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Post/%f')" \
    --relationships=IS_PART_OF="${NEO4J_HEADER_DIR}/static/Place_isPartOf_Place${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/Place_isPartOf_Place -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/Place_isPartOf_Place/%f')" \
    --relationships=IS_SUBCLASS_OF="${NEO4J_HEADER_DIR}/static/TagClass_isSubclassOf_TagClass${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/TagClass_isSubclassOf_TagClass -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/TagClass_isSubclassOf_TagClass/%f')" \
    --relationships=IS_LOCATED_IN="${NEO4J_HEADER_DIR}/static/Organisation_isLocatedIn_Place${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/Organisation_isLocatedIn_Place -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/Organisation_isLocatedIn_Place/%f')" \
    --relationships=HAS_TYPE="${NEO4J_HEADER_DIR}/static/Tag_hasType_TagClass${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/static/Tag_hasType_TagClass -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/static/Tag_hasType_TagClass/%f')" \
    --relationships=HAS_CREATOR="${NEO4J_HEADER_DIR}/dynamic/Comment_hasCreator_Person${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Comment_hasCreator_Person -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Comment_hasCreator_Person/%f')" \
    --relationships=IS_LOCATED_IN="${NEO4J_HEADER_DIR}/dynamic/Comment_isLocatedIn_Country${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Comment_isLocatedIn_Country -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Comment_isLocatedIn_Country/%f')" \
    --relationships=REPLY_OF="${NEO4J_HEADER_DIR}/dynamic/Comment_replyOf_Comment${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Comment_replyOf_Comment -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Comment_replyOf_Comment/%f')" \
    --relationships=REPLY_OF="${NEO4J_HEADER_DIR}/dynamic/Comment_replyOf_Post${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Comment_replyOf_Post -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Comment_replyOf_Post/%f')" \
    --relationships=CONTAINER_OF="${NEO4J_HEADER_DIR}/dynamic/Forum_containerOf_Post${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Forum_containerOf_Post -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Forum_containerOf_Post/%f')" \
    --relationships=HAS_MEMBER="${NEO4J_HEADER_DIR}/dynamic/Forum_hasMember_Person${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Forum_hasMember_Person -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Forum_hasMember_Person/%f')" \
    --relationships=HAS_MODERATOR="${NEO4J_HEADER_DIR}/dynamic/Forum_hasModerator_Person${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Forum_hasModerator_Person -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Forum_hasModerator_Person/%f')" \
    --relationships=HAS_TAG="${NEO4J_HEADER_DIR}/dynamic/Forum_hasTag_Tag${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Forum_hasTag_Tag -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Forum_hasTag_Tag/%f')" \
    --relationships=HAS_INTEREST="${NEO4J_HEADER_DIR}/dynamic/Person_hasInterest_Tag${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_hasInterest_Tag -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_hasInterest_Tag/%f')" \
    --relationships=IS_LOCATED_IN="${NEO4J_HEADER_DIR}/dynamic/Person_isLocatedIn_City${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_isLocatedIn_City -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_isLocatedIn_City/%f')" \
    --relationships=KNOWS="${NEO4J_HEADER_DIR}/dynamic/Person_knows_Person${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_knows_Person -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_knows_Person/%f')" \
    --relationships=LIKES="${NEO4J_HEADER_DIR}/dynamic/Person_likes_Comment${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_likes_Comment -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_likes_Comment/%f')" \
    --relationships=LIKES="${NEO4J_HEADER_DIR}/dynamic/Person_likes_Post${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_likes_Post -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_likes_Post/%f')" \
    --relationships=HAS_CREATOR="${NEO4J_HEADER_DIR}/dynamic/Post_hasCreator_Person${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Post_hasCreator_Person -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Post_hasCreator_Person/%f')" \
    --relationships=HAS_TAG="${NEO4J_HEADER_DIR}/dynamic/Comment_hasTag_Tag${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Comment_hasTag_Tag -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Comment_hasTag_Tag/%f')" \
    --relationships=HAS_TAG="${NEO4J_HEADER_DIR}/dynamic/Post_hasTag_Tag${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Post_hasTag_Tag -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Post_hasTag_Tag/%f')" \
    --relationships=IS_LOCATED_IN="${NEO4J_HEADER_DIR}/dynamic/Post_isLocatedIn_Country${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Post_isLocatedIn_Country -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Post_isLocatedIn_Country/%f')" \
    --relationships=STUDY_AT="${NEO4J_HEADER_DIR}/dynamic/Person_studyAt_University${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_studyAt_University -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_studyAt_University/%f')" \
    --relationships=WORK_AT="${NEO4J_HEADER_DIR}/dynamic/Person_workAt_Company${NEO4J_HEADER_EXTENSION}$(find ${NEO4J_CSV_DIR}/dynamic/Person_workAt_Company -type f -name ${NEO4J_PART_FIND_PATTERN} -printf ,${NEO4J_CSV_DIR}'/dynamic/Person_workAt_Company/%f')" \
    --delimiter '|'