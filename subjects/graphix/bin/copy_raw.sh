#!/bin/bash
# ------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ------------------------------------------------------------

if [ $# -ne 1 ]; then
    echo "Usage: copy_raw.sh [SF]"
    exit 1
fi

# Gets the absolute path so that the script can work no matter where it is invoked.
pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null
AWS_PATH=`dirname "${SCRIPT_PATH}"`
OPT_PATH=`dirname "${AWS_PATH}"`
DIST_PATH=`dirname "${OPT_PATH}"`

# Users should specify the scale factor to copy.
SF=$1
NC1=$(grep ncs ${AWS_PATH}/conf/instance/inventory -A 1 | tail -n 1)
ssh ec2-user@$NC1 "rm -rf /data1/raw-data/"
ssh ec2-user@$NC1 "mkdir -p /data1/raw-data/dynamic /data1/raw-data/static"
ssh ec2-user@$NC1 "cp -r /data0/sf-${SF}/graphs/csv/bi/composite-projected-fk/initial_snapshot/dynamic/. /data1/raw-data/dynamic"
ssh ec2-user@$NC1 "cp -r /data0/sf-${SF}/graphs/csv/bi/composite-projected-fk/initial_snapshot/static/. /data1/raw-data/static"

