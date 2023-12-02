#!/bin/bash

# Gets the absolute path so that the script can work no matter where it is invoked.
pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null
AWS_PATH=`dirname "${SCRIPT_PATH}"`
OPT_PATH=`dirname "${AWS_PATH}"`
DIST_PATH=`dirname "${OPT_PATH}"`

if [ $# -ne 1 ]; then
    echo "Usage: setup.sh [SF]"
    exit 1
fi

# Note: we are assuming that our CC is also an NC (makes our life easier here).
CC_PUBLIC_ADDRESS=$(grep cc ${AWS_PATH}/conf/instance/inventory -A 1 | tail -n 1)
CC_PRIVATE_ADDRESS=$(grep cc ${AWS_PATH}/conf/instance/cc.conf -A 1 | tail -n 1 | cut -d "=" -f 2)
echo "CC IP addresses are $CC_PUBLIC_ADDRESS (public) and $CC_PRIVATE_ADDRESS (private)."

# First, our external dataset.
python3 ~/setup/run-statement.py \
  --file ~/setup/create-s1.sqlpp \
  --uri http://$CC_PUBLIC_ADDRESS:19002 \
  --sub DATA_PATH,$CC_PRIVATE_ADDRESS:///data0/sf-$1/graphs/csv/bi/composite-projected-fk/initial_snapshot/
sleep 5

# Next, we will copy the JSONL files to our CC node.
ssh ec2-user@$CC_PUBLIC_ADDRESS "rm -rf /data1/raw-data/"
ssh ec2-user@$CC_PUBLIC_ADDRESS "mkdir -p /data1/raw-data/"
ssh ec2-user@$CC_PUBLIC_ADDRESS "cp -r /data0/sf-$1/graphs/json/. /data1/raw-data/"

# Finally... the rest. :-)
for i in 2 3a 3b 3c 3d 3e 3f 3g 3h 4 5; do
  python3 ~/setup/run-statement.py \
    --file ~/setup/create-s$i.sqlpp \
    --uri http://$CC_PUBLIC_ADDRESS:19002 \
    --sub DATA_PATH,$CC_PRIVATE_ADDRESS:///data1/raw-data/
  sleep 5
done

# Clean up our mess.
ssh ec2-user@$CC_PUBLIC_ADDRESS "rm -rf /data1/raw-data/"