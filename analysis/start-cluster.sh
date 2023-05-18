#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null

"${SCRIPT_PATH}"/asterixdb/bin/asterixncservice &
sleep 5
"${SCRIPT_PATH}"/asterixdb/bin/asterixcc -config-file "${SCRIPT_PATH}"/asterixdb/cc.conf -log-dir "${SCRIPT_PATH}"/asterixdb/logs &
"${SCRIPT_PATH}"/asterixdb/bin/asterixhelper wait_for_cluster -clusteraddress 127.0.0.1