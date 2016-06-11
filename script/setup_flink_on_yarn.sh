#!/bin/bash

## NOTES
# 1. We have to install Ganglia web server manually

isCloudLab=true
isAmazonEC=false

java_home='/usr/lib/jvm/java-8-openjdk-amd64'

hadoopVer="hadoop-2.7.0"
hadoopLink="http://download.nextag.com/apache/hadoop/common/hadoop-2.7.0/hadoop-2.7.0.tar.gz"
hadoopTgz="hadoop-2.7.0.tar.gz"

flinkTar="flink.tar"
flinkVer="flink-1.0.3"
flinkTgz="flink-1.0.3-bin-hadoop27-scala_2.10.tgz"
flinkDownloadLink="http://apache.mesi.com.ar/flink/flink-1.0.3/flink-1.0.3-bin-hadoop27-scala_2.10.tgz"
flinkSrc="/home/tanle/projects/Flink"
testCase="../flink-test-cases"

###########
vmemRatio=4
yarnNodeMem=65536 # 32768
yarnMaxMem=32768
scheduler="org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler"
#scheduler="org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"
#schedulerFile="/users/tanle/$hadoopVer/etc/hadoop/fair-scheduler.xml"
#schedulerFile="/users/tanle/fair-scheduler.xml"
schedulerFile="/users/tanle/hadoop-2.7.0/share/hadoop/tools/sls/sample-conf/fair-scheduler.xml"
yarnVcores=32
hdfsDir="/dev/hdfs"
yarnAppLogs="/dev/yarn-logs"
#hdfsDir="/users/tanle/hdfs"
#hdfsDir="/proj/yarnrm-PG0/hdfs"
numOfReplication=3
numNetworkBuffers=4096 # default 2048
##########

#log-dirs are bad: /users/tanle/hadoop-2.7.0/logs/userlogs


REBOOT=false
isOfficial=true
isSingleNodeCluster=false;

isUploadTestCase=false


isDownload=false
isExtract=true

isUploadKey=false
isGenerateKey=false
isPasswordlessSSH=false

isInstallBasePackages=false

isInstallGanglia=false
startGanglia=false
if $isInstallGanglia
then
	startGanglia=true
fi

isInstallHadoop=true
isInitPath=false
isModifyHadoop=false
isShutDownHadoop=false
restartHadoop=false
isFormatHDFS=false

if $isInstallHadoop
then
	isShutDownHadoop=true
	restartHadoop=true
	isFormatHDFS=true
fi

isInstallFlink=false
isModifyFlink=false
startFlinkYarn=true
shudownFlink=false

startFlinkStandalone=false # not necessary

isRun=false


if $isCloudLab
then
	masterNode="nm"
	clientNode="ctl"

	privateKey="/home/tanle/Dropbox/Papers/System/Flink/cloudlab/cloudlab.pem"
	if $isOfficial
	then
		numOfworkers=14
		serverList="nm cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-14"
		slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-14"
		numOfReplication=3
	else
		numOfworkers=1
		serverList="nm cp-1"
		slaveNodes="cp-1"
		numOfReplication=1		
	fi
elif $isAmazonEC
then
	echo "Amazon EC"
else
	if $isSingleNodeCluster
	then
		masterNode="localhost"
		serverList="localhost"
		slaveNodes="localhost"
		numOfReplication=1
		numOfworkers=1
		isUploadKey=false
	fi
fi


if $REBOOT
then
echo ############### REBOOT all servers #############################	
	while true; do
	    read -p "Do you wish to reboot the whole cluster?" yn
	    case $yn in
		[Yy]* ) make install; break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	    esac
	done

	for server in $serverList; do		
		echo reboot server $server
		ssh tanle@$server "ssh $server 'sudo reboot'" &
	done
	wait
fi



if $isUploadKey
then		
echo ################################# passwordless SSH ####################################
	if $isGenerateKey 
	then 	
		sudo rm -rf $HOME/.ssh/id_dsa*
		sudo rm -rf $HOME/.ssh/authorized_keys*
		yes Y | ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa 		
		sudo chmod 600 $HOME/.ssh/id_dsa*
		echo 'StrictHostKeyChecking no' >> ~/.ssh/config
#		ssh-add $privateKey
	fi
	rm -rf ~/.ssh/known_hosts
	for server in $serverList; do
		echo upload keys to $server
		if ! $isSingleNodeCluster
		then
			ssh tanle@$server 'sudo rm -rf $HOME/.ssh/id_dsa*'
			scp ~/.ssh/id_dsa* tanle@$server:~/.ssh/
		fi
		ssh tanle@$server "cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys ;
		 chmod 0600 ~/.ssh/id_dsa*; 
		 chmod 0600 ~/.ssh/authorized_keys; 
		 rm -rf ~/.ssh/known_hosts; 	
		 echo 'StrictHostKeyChecking no' >> ~/.ssh/config"
#		ssh tanle@$server "echo password less from localhost to $server"
	done	
fi
if $isPasswordlessSSH
then
	passwordlessSSH () { echo $1 to $2;	ssh tanle@$1 "ssh $2 'echo test passwordless SSH'" ;}
	for server1 in $serverList; do
		for server2 in $serverList; do
			passwordlessSSH $server1 $server2 &
		done
	done
	wait
fi

if $isInstallBasePackages
then
	echo ################################# install JAVA ######################################
	installJava () {
		ssh tanle@$1 'yes Y | sudo apt-get install openjdk-8-jdk'
	}
	echo "TODO: install JAVA"
	for server in $serverList; do
		installJava $server &
	done
	wait
	echo ################################ install screen #####################################
	ssh tanle@$masterNode "sudo apt-get -u install screen"
fi


if $isInstallGanglia
then
echo ################################# install Ganglia ###################################
	echo "Configure Ganglia master node $masterNode"
	ssh tanle@$masterNode 'yes Y | sudo apt-get purge ganglia-monitor gmetad'
	### PLZ manually install Ganglia as we need to respond to some pop-ups
	# we may restart the Apache2 twice
	#ssh tanle@$masterNode 'sudo apt-get install -y rrdtool  ganglia-webfrontend'
	ssh tanle@$masterNode 'sudo apt-get install -y ganglia-monitor gmetad'
	
	# 
	ssh tanle@$masterNode "sudo cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf ;
	sudo sed -i -e 's/data_source \"my cluster\" localhost/data_source \"sbu flink\" 1 localhost/g' /etc/ganglia/gmetad.conf;
	sudo sed -i -e 's/name = \"unspecified\"/name = \"sbu flink\"/g' /etc/ganglia/gmond.conf ;
	sudo sed -i -e 's/mcast_join = 239.2.11.71/#mcast_join = 239.2.11.71/g' /etc/ganglia/gmond.conf;
	sudo sed -i -e 's/bind = 239.2.11.71/#bind = 239.2.11.71/g' /etc/ganglia/gmond.conf;
	sudo sed -i -e 's/udp_send_channel {/udp_send_channel { host=nm/g' /etc/ganglia/gmond.conf"
	
	installGangliaFunc(){
		ssh tanle@$1 "sudo apt-get install -y ganglia-monitor;
		sudo sed -i -e 's/name = \"unspecified\"/name = \"sbu flink\"/g' /etc/ganglia/gmond.conf;
		sudo sed -i -e 's/mcast_join = 239.2.11.71/#mcast_join = 239.2.11.71/g' /etc/ganglia/gmond.conf;
		sudo sed -i -e 's/udp_send_channel {/udp_send_channel { host=nm/g' /etc/ganglia/gmond.conf"
	}

	for server in $slaveNodes; do
		installGangliaFunc $server &
	done	
	wait

fi

if $startGanglia
then
	echo restart Ganglia
	# restart all related services
	ssh tanle@$masterNode 'sudo service ganglia-monitor restart & sudo service gmetad restart & sudo service apache2 restart'
	for server in $slaveNodes; do
		ssh tanle@$server 'sudo service ganglia-monitor restart' &
	done
	wait	
fi


if $isShutDownHadoop
then
	echo shutdown Hadoop and Yarn
	ssh tanle@$masterNode "$hadoopVer/sbin/stop-dfs.sh;
	$hadoopVer/sbin/stop-yarn.sh"
#	$hadoopVer/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop proxyserver"
#	ssh tanle@$masterNode "$hadoopVer/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver"
fi 
if $isInstallHadoop
then
echo "#################################### install Hadoop Yarn ####################################"
# http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html
	if $isModifyHadoop 
	then 
		echo "TODO: enter the hadoop source code folder"	
	else

		installHadoopFunc () {
			echo Set up Hadoop at $1
			if $isDownload
			then		
				echo downloading $hadoopVer		
				ssh tanle@$1 "rm -rf $hadoopTgz; wget $hadoopLink"
			fi
			if $isExtract
			then 
				echo extract $hadoopTgz
				ssh tanle@$1 "rm -rf $hadoopVer; tar -xvzf $hadoopTgz >> log.txt"	
			fi
			# add JAVA_HOME
			echo Configure Hadoop at $1
			ssh tanle@$1 "echo export JAVA_HOME=$java_home > temp.txt"			
			ssh tanle@$1 "cat temp.txt ~/$hadoopVer/etc/hadoop/hadoop-env.sh > temp2.txt ; mv temp2.txt ~/$hadoopVer/etc/hadoop/hadoop-env.sh"

			if $isInitPath
			then	
				ssh tanle@$1 "echo export JAVA_HOME=$java_home >> .bashrc"				
				# Administrators can configure individual daemons using the configuration options shown below in the table:	
				#ssh tanle@$1 'echo export HADOOP_NAMENODE_OPTS="-XX:+UseParallelGC" > temp.txt'
				#ssh tanle@$1 "cat /$hadoopVer/etc/hadoop/hadoop-env.sh temp.txt > temp2.txt; mv temp2.txt /$hadoopVer/etc/hadoop/hadoop-env.sh"
				# HADOOP_DATANODE_OPTS
	 			# HADOOP_DATANODE_OPTS
				# HADOOP_SECONDARYNAMENODE_OPTS	
				# YARN_RESOURCEMANAGER_OPTS
				# YARN_NODEMANAGER_OPTS
				# YARN_PROXYSERVER_OPTS
				# HADOOP_JOB_HISTORYSERVER_OPTS
			
				# Other useful configuration parameters for hadoop & yarn
				# HADOOP_PID_DIR - The directory where the daemons’ process id files are stored.
				# HADOOP_LOG_DIR - The directory where the daemons’ log files are stored. 
				# HADOOP_HEAPSIZE
				# ssh tanle@$1 "sed -i -e 's/#export HADOOP_HEAPSIZE=/export HADOOP_HEAPSIZE=4096/g' $hadoopVer/etc/hadoop/hadoop-env.sh"
				# YARN_HEAPSIZE
				# ssh tanle@$server "sed -i -e 's/# YARN_HEAPSIZE=1000/# YARN_HEAPSIZE=4096/g' $hadoopVer/etc/hadoop/yarn-env.sh"
			
				# configure HADOOP_PREFIX 
				ssh tanle@$1 "echo export HADOOP_PREFIX=~/$hadoopVer >> .bashrc;
				echo export HADOOP_CONF_DIR=~/$hadoopVer/etc/hadoop >> .bashrc;
				echo export HADOOP_YARN_HOME=~/$hadoopVer >> .bashrc;
				echo export HADOOP_HOME=~/$hadoopVer >> .bashrc;				
				echo export HADOOP_CONF_DIR=~/$hadoopVer/etc/hadoop >> .bashrc;
				echo export YARN_CONF_DIR=~/$hadoopVer/etc/hadoop >> .bashrc"
			fi

			# etc/hadoop/core-site.xml
			ssh tanle@$1 "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"

			ssh tanle@$1 "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>

  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://$masterNode:9000/</value>
  </property>

  <property>
    <name>io.file.buffer.size</name>
    <value>131072</value>
  </property>

  <property>
    <name>hadoop.tmp.dir</name>
    <value>$hdfsDir</value>
  </property>

</configuration>' > $hadoopVer/etc/hadoop/core-site.xml"

			# etc/hadoop/hdfs-site.xml
			ssh tanle@$1 "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?> 
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>

  <property> 
    <name>dfs.replication</name>
    <value>$numOfReplication</value>
  </property>

  <property>
    <name>dfs.blocksize</name>
    <value>268435456</value>
  </property>

  <property>
    <name>dfs.namenode.handler.count</name>
    <value>100</value>
  </property>

</configuration>' > $hadoopVer/etc/hadoop/hdfs-site.xml"

			echo Configure Yarn at $1

			# etc/hadoop/yarn-site.xml
			## Configurations for ResourceManager and NodeManager:

			ssh tanle@$1 "sudo rm -rf $yarnAppLogs; sudo mkdir $yarnAppLogs; sudo chmod 777 $yarnAppLogs" 

			ssh tanle@$1 "echo '<?xml version=\"1.0\"?>
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>

  <property>
    <name>yarn.resourcemanager.scheduler.class</name>
    <value>$scheduler</value>
  </property>

  <property>
    <name>yarn.scheduler.fair.allocation.file</name>
    <value>$schedulerFile</value>
  </property> 


  <property>
    <name>yarn.resourcemanager.address</name>
    <value>nm:8040</value>
  </property>

  <property>
    <name>yarn.resourcemanager.scheduler.address</name>
    <value>nm:8030</value>
  </property>

  <property>
    <name>yarn.resourcemanager.resource-tracker.address</name>
    <value>nm:8025</value>
  </property>

  <property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>$yarnMaxMem</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>$yarnVcores</value>
  </property>

  <property>
    <name>yarn.scheduler.maximum-allocation-vcores</name>
    <value>32</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>$yarnNodeMem</value>
  </property>

  <property>
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>$vmemRatio</value>
  </property>

<property>
    <name>yarn.nodemanager.log-dirs</name>
    <value>$yarnAppLogs</value>
  </property>

</configuration>' > $hadoopVer/etc/hadoop/yarn-site.xml"

# setup scheduler https://hadoop.apache.org/docs/r2.7.1/hadoop-yarn/hadoop-yarn-site/FairScheduler.html
if false
then

			ssh tanle@$1 "echo '<?xml version="1.0"?>
<allocations>
  <queue name=\"sample_queue\">
    <minResources>10000 mb,0vcores</minResources>
    <maxResources>90000 mb,0vcores</maxResources>
    <maxRunningApps>50</maxRunningApps>
    <weight>2.0</weight>
    <schedulingPolicy>fair</schedulingPolicy>
    <queue name=\"sample_sub_queue\">
      <aclSubmitApps>charlie</aclSubmitApps>
      <minResources>5000 mb,0vcores</minResources>
    </queue>
  </queue>
  
  <user name=\"sample_user\">
    <maxRunningApps>30</maxRunningApps>
  </user>
  <userMaxAppsDefault>5</userMaxAppsDefault>
  
  <queuePlacementPolicy>
    <rule name=\"specified\" />
    <rule name=\"primaryGroup\" create="false" />
    <rule name=\"default\" />
  </queuePlacementPolicy>
</allocations>
' > $schedulerFile"

fi
			
			# etc/hadoop/mapred-site.xml
			ssh tanle@$1 "echo '<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>

  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>

  <property>
    <name>mapreduce.map.memory.mb</name>
    <value>1536</value>
  </property>

  <property>
    <name>mapreduce.map.java.opts</name>
    <value>-Xmx1024M</value>
  </property>

  <property>
    <name>mapreduce.reduce.memory.mb</name>
    <value>3072</value>
  </property>

  <property>
    <name>mapreduce.reduce.java.opts</name>
    <value>-Xmx2560M</value>
  </property>

  <property>
    <name>mapreduce.task.io.sort.mb</name>
    <value>512</value>
  </property>

  <property>
    <name>mapreduce.task.io.sort.factor</name>
    <value>100</value>
  </property>

  <property>
    <name>mapreduce.reduce.shuffle.parallelcopies</name>
    <value>50</value>
  </property>

</configuration>' > $hadoopVer/etc/hadoop/mapred-site.xml"
			
			# monitoring script in etc/hadoop/yarn-site.xml

			# slaves etc/hadoop/slaves
			ssh tanle@$1 "rm -rf $hadoopVer/etc/hadoop/slaves"
			for svr in $slaveNodes; do
				ssh tanle@$1 "echo $svr >> $hadoopVer/etc/hadoop/slaves"
			done	

}
		for server in $serverList; do
			installHadoopFunc $server &
		done

		wait				
	fi
fi


if $restartHadoop
then
	# shutdown all before starting.
	echo "============================stopping Hadoop (HDFS) and Yarn ========================="
	ssh tanle@$masterNode "$hadoopVer/sbin/stop-dfs.sh; $hadoopVer/sbin/stop-yarn.sh"
	echo '============================ starting Hadoop==================================='

	if $isFormatHDFS
	then
		ssh tanle@$masterNode "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
		ssh tanle@$masterNode "yes Y | $hadoopVer/bin/hdfs namenode -format HDFS4Flink"
	fi
	ssh tanle@$masterNode "$hadoopVer/sbin/start-dfs.sh"
	echo '============================ starting Yarn==================================='
	# operating YARN
	ssh tanle@$masterNode "$hadoopVer/sbin/start-yarn.sh"
	# operating MapReduce
	#ssh tanle@$masterNode '$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver'

	
fi


#################################### Apache Flink ################################
if $shudownFlink
then
	ssh $masterNode "$flinkVer/bin/stop-cluster.sh"
	#ssh $masterNode "$hadoopVer/bin/yarn application -kill appplication_id"
fi

if $isInstallFlink 
then 	
	installFlinkFunc () {
		if $isDownload
		then
		ssh $1 "rm -rf $flinkTgz; wget $flinkDownloadLink"
		fi
		if $isExtract
		then
			ssh $1 "rm -rf $flinkVer; tar -xvzf $flinkTgz"
		fi
		
		#Replace localhost with resourcemanager in conf/flink-conf.yaml (jobmanager.rpc.address)
		ssh $1 "sed -i -e 's/jobmanager.rpc.address: localhost/jobmanager.rpc.address: nm/g' $flinkVer/conf/flink-conf.yaml;
		sed -i -e 's/jobmanager.heap.mb: 256/taskmanager.heap.mb: 1024/g' $flinkVer/conf/flink-conf.yaml;		
		sed -i -e 's/taskmanager.heap.mb: 512/taskmanager.heap.mb: $yarnMaxMem/g' $flinkVer/conf/flink-conf.yaml;	
		sed -i -e 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: $yarnVcores/g' $flinkVer/conf/flink-conf.yaml;
		sed -i -e 's/# taskmanager.network.numberOfBuffers: 2048/taskmanager.network.numberOfBuffers: $numNetworkBuffers/g' $flinkVer/conf/flink-conf.yaml"

		#Add hostnames of all worker nodes to the slaves file flinkVer/conf/slaves"
		ssh $1 "rm -rf $flinkVer/conf/slaves"
		for slave in $slaveNodes; do
			ssh $1 "echo $slave >> $flinkVer/conf/slaves"
		done	
	}
	for server in $serverList; do
		installFlinkFunc $server &
	done
	wait
fi


if $startFlinkStandalone	
then
	ssh $masterNode "$flinkVer/bin/stop-cluster.sh"
	ssh $masterNode "$flinkVer/bin/start-cluster.sh"
fi	
if $startFlinkYarn
then
	echo ############################ start Yars session for Flink#########################
#	ssh $masterNode "$flinkVer/bin/yarn-session.sh -n $numOfworkers -d -jm 1024 -tm $yarnMaxMem -s $yarnVcores"
	echo "~/$flinkVer/bin/yarn-session.sh -n $numOfworkers -d -st -jm 1024 -tm $yarnMaxMem -s $yarnVcores"
	echo "~/$flinkVer/bin/yarn-session.sh -n $numOfworkers -d -st"
fi

############################################### TEST CASES ###########################################
# upload test cases
if $isUploadTestCase 
then 
	cd $flinkSrc	
	rm -rf test/wordcount/*.txt test/wordcount/*.out test/wordcount/*.log
	tar zcvf test.tar $testCase
	ssh tanle@$masterNode 'rm -rf test*'
	scp test.tar tanle@$masterNode:~/ 
	ssh tanle@$masterNode 'tar -xvzf test.tar'

	rm -rf test.tar
fi
