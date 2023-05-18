#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null

"${SCRIPT_PATH}"/asterixdb/bin/asterixhelper shutdown_cluster_all
sleep 10
if ps -ef | grep 'java.*org\.apache\.hyracks\.control\.[cn]c\.\([CN]CDriver\|service\.NCService\)' > /tmp/$$_pids; then
  cat /tmp/$$_pids | while read line; do
    echo -n "   - $line..."
    echo $line | awk '{ print $2 }' | xargs -n1 kill -9
    echo "killed"
  done
fi
rm /tmp/$$_pids