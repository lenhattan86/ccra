#!/bin/bash

hadoopFolder="hadoop"
configFolder="etc/hadoop"
tezConfigFolder="etc/tez"

masterNode="localhost"
username="tanle"
SSH_CMD="autossh"
hdfsDir="/dev/hdfs"

########################## restart all #########################

$SSH_CMD $username@$masterNode "$hadoopFolder/bin/yarn application -kill appplication_id"
$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/stop-yarn.sh"
