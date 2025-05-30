#!/bin/bash

# Gets the absolute path so that the script can work no matter where it is invoked.
pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null
AWS_PATH=`dirname "${SCRIPT_PATH}"`
OPT_PATH=`dirname "${AWS_PATH}"`
DIST_PATH=`dirname "${OPT_PATH}"`

if [ $# -ne 1 ]; then
    echo "Usage: print.sh [cc|nc-*]"
    exit 1
fi

if [[ $1 == "cc" ]]; then
  grep cc ${AWS_PATH}/conf/instance/inventory -A 1 | tail -n 1

elif [[ $1 == "nc-"* ]]; then
    echo "Not implemented! :-)"
    exit 1
fi
