#!/bin/bash

GRAPHIX_NODE_IP="xxx.xxx.xxx.xxx"
NEO4J_NODE_IP="xxx.xxx.xxx.xxx"

if [ $# -ne 1 ]; then
  echo "Usage: restart-database.sh [neo4j|graphix-*]"
  exit 1
fi

if [ "$1" == "neo4j" ]; then
  TMP_FILE=$(mktemp)
  touch "$TMP_FILE"
  {
    echo 'sudo neo4j stop'
    echo 'sleep 10'
    echo "NEO4J_STATUS=\$(neo4j status 2>&1 | head -n1)"
    echo "if [[ \$NEO4J_STATUS == *'Neo4j is not running'* ]]; then"
    echo '  sudo neo4j start'
    echo '  sleep 10'
    echo 'else'
    echo "  sudo kill -9 \$(echo \$NEO4J_STATUS | sed -n 's/.*pid \([0-9]*\).*/\1/p')"
    echo '  sleep 10'
    echo '  sudo neo4j start'
    echo '  sleep 10'
    echo 'fi'
    echo 'sleep 120'
  } >> "$TMP_FILE"
  ssh -T -i /home/ec2-user/ldbc-snb-kp.pem $NEO4J_NODE_IP 'bash -s' < "$TMP_FILE"
  sleep 1
  rm "$TMP_FILE"

elif [[ "$1" == "graphix-"* ]]; then
  TMP_FILE=$(mktemp)
  touch "$TMP_FILE"
  {
    echo 'ssh-agent bash'
    echo 'ssh-add /home/ec2-user/ldbc-snb-kp.pem'
    echo 'echo "Stopping Graphix..."'
    echo "/home/ec2-user/$1/opt/aws/bin/stop.sh"
    echo 'sleep 30'
    echo 'echo "Starting Graphix..."'
    echo "/home/ec2-user/$1/opt/aws/bin/start.sh"
    echo "sleep 60"
    echo "CC_CONF=/home/ec2-user/$1/opt/aws/conf/instance/cc.conf"
    echo "/home/ec2-user/$1/bin/asterixhelper wait_for_cluster -clusteraddress \$(cat \$CC_CONF | grep cc -A1 | tail -n 1 | cut -d '=' -f 2)"
    echo "sleep 10"
    echo "echo 'Killing SSH agent...'"
    echo "ssh-agent -k"
    echo "echo 'Graphix should now be restarted!'"
    echo "exit"
  } >> "$TMP_FILE"
  ssh -T -i /home/ec2-user/ldbc-snb-kp.pem $GRAPHIX_NODE_IP 'bash -s' < "$TMP_FILE"
  sleep 1
  rm "$TMP_FILE"
else
  echo "Usage: restart-database.sh [neo4j|graphix-*]"
  exit 1
fi
