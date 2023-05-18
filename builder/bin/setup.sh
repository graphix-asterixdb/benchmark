#!/bin/bash

# Gets the absolute path so that the script can work no matter where it is invoked.
pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null
AWS_PATH=`dirname "${SCRIPT_PATH}"`
OPT_PATH=`dirname "${AWS_PATH}"`
DIST_PATH=`dirname "${OPT_PATH}"`

CC_PUBLIC_ADDRESS=$(grep cc ${AWS_PATH}/conf/instance/inventory -A 1 | tail -n 1)
CC_PRIVATE_ADDRESS=$(grep cc ${AWS_PATH}/conf/instance/cc.conf -A 1 | tail -n 1 | cut -d "=" -f 2)

for i in 1 2 3 4 5 6; do
  python3 ~/setup/run-statement.py \
    --file ~/setup/create-s$i.sqlpp \
    --uri http://$CC_PUBLIC_ADDRESS:19002 \
    --sub DATA_PATH,$CC_PRIVATE_ADDRESS:///data1/raw-data/
done