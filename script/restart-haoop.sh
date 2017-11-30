#!/bin/bash

hadoopFolder="hadoop"
configFolder="etc/hadoop"
tezConfigFolder="etc/tez"


if [ -z "$1" ]
then
	#masterNode="localhost"
	masterNode="ctl.yarn-drf.yarnrm-pg0.clemson.cloudlab.us"
else
	masterNode="$1"
fi
username="tanle"
SSH_CMD="autossh"
hdfsDir="/dev/hdfs"

########################## restart all #########################

# shutdown all before starting.
echo "============================stopping Hadoop (HDFS) and Yarn ========================="
$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/stop-dfs.sh; $hadoopFolder/sbin/stop-yarn.sh"
echo '============================ starting Hadoop==================================='

$SSH_CMD $username@$masterNode "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
$SSH_CMD $username@$masterNode "yes Y | $hadoopFolder/bin/hdfs namenode -format HDFS4Flink"

sleep 30

$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/start-dfs.sh"

sleep 30
echo '============================ starting Yarn==================================='
# operating YARN
$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/start-yarn.sh"

$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -mkdir /apps"
$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -mkdir /apps/tez"
scp ~/projects/BPFImpl/tez/tez-dist/target/tez-0.8.4.tar.gz $username@$masterNode:~/
$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -rmr /apps/tez/tez-0.8.4.tar.gz;
hadoop/bin/hadoop dfs -copyFromLocal tez-0.8.4.tar.gz /apps/tez/"	

