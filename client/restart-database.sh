#!/bin/bash

BUILDER_NODE_IP="54.151.125.221"
NEO4J_SVSS_NODE_IP="13.52.46.19"

if [ $# -ne 1 ]; then
  echo "Usage restart-database.sh [neo4j|graphix-*|tigergraph]"
  exit 1
fi

if [ "$1" == "neo4j" ]; then
  ssh -T -i /home/ec2-user/ldbc-snb-kp.pem $NEO4J_SVSS_NODE_IP <<"EOF"
        sudo neo4j restart
EOF
  sleep 100

elif [[ "$1" == "graphix-"* ]]; then
  TMP_FILE=$(mktemp)
  touch "$TMP_FILE"
  {
    echo 'ssh-agent bash'
    echo 'ssh-add /home/ec2-user/ldbc-snb-kp.pem'
    echo "/home/ec2-user/$1/opt/aws/bin/stop.sh"
    echo 'sleep 5'
    echo "/home/ec2-user/$1/opt/aws/bin/start.sh"
    echo "CC_CONF=/home/ec2-user/$1/opt/aws/conf/instance/cc.conf"
    echo "/home/ec2-user/$1/bin/asterixhelper wait_for_cluster -clusteraddress \$(cat \$CC_CONF | grep cc -A1 | tail -n 1 | cut -d '=' -f 2)"
  } >> "$TMP_FILE"
  ssh -T -i /home/ec2-user/ldbc-snb-kp.pem $BUILDER_NODE_IP 'bash -s' < "$TMP_FILE"
  sleep 1
  rm "$TMP_FILE"
else
  echo "Usage restart-database.sh [neo4j|graphix-*|tigergraph]"
  exit 1
fi
