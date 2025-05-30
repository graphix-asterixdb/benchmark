#!/bin/bash

if (($# != 2)); then
  echo "Usage: query.sh [query file] [output file]"
  exit 1
fi

# We have two arguments. :-)
QUERY_FILE_NAME=$1
OUTPUT_FILE_NAME=$2
echo "Executing query from $QUERY_FILE_NAME and writing results to $OUTPUT_FILE_NAME."

# Run our query.
HANDLE=$(\
  curl -s \
    --data-urlencode "statement=$(cat ${QUERY_FILE_NAME})" \
    --data-urlencode "format=ADM" \
    --data-urlencode "mode=deferred" \
    http://localhost:19002/query/service | \
  jq -r -c '.handle'\
)
echo "Result handle returned: $HANDLE"

# Retrieving results.
echo "Now retrieving results."
curl -s $HANDLE >> $OUTPUT_FILE_NAME
echo "Done!"