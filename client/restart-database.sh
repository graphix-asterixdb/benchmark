#!/bin/bash

BUILDER_NODE_IP=xxxx
NEO4J_SVSS_NODE_IP=xxxx

if [ $# -ne 1 ]; then
  echo "Usage restart-database.sh [neo4j|builder]"
  exit 1
fi

if [ "$1" == "neo4j" ]; then
  ssh -T -i /home/ec2-user/ldbc-snb-kp.pem $NEO4J_SVSS_NODE_IP <<"EOF"
        sudo neo4j restart
EOF
  sleep 100

elif [ "$1" == "builder" ]; then
  ssh -T -i /home/ec2-user/ldbc-snb-kp.pem $BUILDER_NODE_IP <<"EOF"
        ssh-agent bash
        ssh-add /home/ec2-user/ldbc-snb-kp.pem
        /home/ec2-user/graphix/opt/aws/bin/stop.sh
        sleep 5
        /home/ec2-user/graphix/opt/aws/bin/start.sh
        CC_CONF=/home/ec2-user/graphix/opt/aws/conf/instance/cc.conf
        /home/ec2-user/graphix/bin/asterixhelper wait_for_cluster \
            -clusteraddress $(cat $CC_CONF | grep cc -A1 | tail -n 1 | cut -d '=' -f 2)
EOF

else
  echo "Usage: restart-database.sh [neo4j|builder]"
  exit 1
fi
