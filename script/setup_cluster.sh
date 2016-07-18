#!/bin/bash

## author: Tan N. Le ~ CS department Stony Brook University

## NOTES
# 1. We have to install Ganglia web server manually
# ssh nm; sudo apt-get install -y rrdtool  ganglia-webfrontend
# 2. Set up path/urf for hadoop, flink, spark, java, ...
# 3. Change true/false to install necessary component.

######################### System Variables #####################

isCloudLab=true
isAmazonEC=false
username="tanle"
groupname="yarnrm-PG0"

java_home='/usr/lib/jvm/java-7-oracle'



######################### Hadoop  #####################
hadoopFolder="hadoop"
configFolder="etc/hadoop"

#hadoopVer="hadoop-2.7.0"
#hadoopLink="http://download.nextag.com/apache/hadoop/common/hadoop-2.7.0/hadoop-2.7.0.tar.gz"
#hadoopTgz="hadoop-2.7.0.tar.gz"


#hadoopVer="hadoop-2.6.4"
#hadoopLink="http://apache.claz.org/hadoop/common/hadoop-2.6.4/hadoop-2.6.4.tar.gz"
#hadoopTgz="hadoop-2.6.4.tar.gz"

hadoopVer="hadoop-2.6.3"
hadoopLink="http://apache.claz.org/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz"
hadoopTgz="hadoop-2.6.3.tar.gz"

vmemRatio=4
#yarnNodeMem=131072 # 128 GB
yarnNodeMem=65536 # 64 GB
#yarnNodeMem=32768 # 32 GB

yarnMaxMem=32768 # for each container
fairSchedulerFile="/users/tanle/$hadoopFolder/etc/fair-scheduler.xml"
capacitySchedulerFile="/users/tanle/$hadoopFolder/etc/capacity-scheduler.xml"
isCapacityScheduler=false
if $isCapacityScheduler
then
	schedulerFile=$capacitySchedulerFile
	scheduler="org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"
else
	schedulerFile=$fairSchedulerFile
	scheduler="org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler" 
fi

yarnVcores=32
hdfsDir="/dev/hdfs"
#yarnAppLogs="/dev/yarn-logs"
#yarnAppLogs="/dev/shm/yarn-logs" # only used in hadoop 2.7
yarnAppLogs="/users/tanle/yarn-logs" # for hadoop 2.6
#hdfsDir="/users/tanle/hdfs"
#hdfsDir="/proj/yarnrm-PG0/hdfs"
cgroupYarn="~/$hadoopFolder/cgroup"
numOfReplication=3

######################### Flink  #####################

flinkTar="flink.tar"
flinkVer="flink-1.0.3"
flinkTgz="flink-1.0.3-bin-hadoop27-scala_2.10.tgz"
flinkDownloadLink="http://apache.mesi.com.ar/flink/flink-1.0.3/flink-1.0.3-bin-hadoop27-scala_2.10.tgz"
flinkSrc="/home/$username/projects/Flink"
testCase="../flink-test-cases"


###########

numNetworkBuffers=4096 # default 2048

######################### Spark  #####################

sparkFolder="spark"
sparkVer="spark-1.6.1"
sparkTgz="spark-1.6.1-bin-hadoop2.6.tgz"
sparkTgzFolder="spark-1.6.1-bin-hadoop2.6"
sparkDownloadLink="http://apache.claz.org/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz"

##########

IS_INIT=false

REBOOT=false
isOfficial=true
isSingleNodeCluster=false;

isUploadTestCase=false


isDownload=false
isExtract=false

isUploadKey=false
isGenerateKey=false
isPasswordlessSSH=false
isAddToGroup=false

isInstallBasePackages=false

isInstallGanglia=false
startGanglia=false
if $isInstallGanglia
then
	startGanglia=true
fi

isInstallHadoop=true
isInitPath=false
if $isDownload
then
	isInitPath=true
fi
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
startFlinkYarn=false
shudownFlink=false
startFlinkStandalone=false # not necessary

isInstallSpark=true
isModifySpark=false
startSparkYarn=false
shudownSpark=false
startSparkStandalone=false # not necessary

isRun=false

if $IS_INIT
then
	isDownload=true
	isExtract=true

	isUploadKey=true
	isGenerateKey=true
	isPasswordlessSSH=true
	isAddToGroup=true

	isInstallBasePackages=true

	isInstallGanglia=true
	startGanglia=true

	isInstallHadoop=true
	isInitPath=true
	isFormatHDFS=true
	restartHadoop=true

	isInstallFlink=true

	isInstallSpark=true
fi

if $isCloudLab
then
	masterNode="nm"
	clientNode="ctl"

	privateKey="/home/$username/Dropbox/Papers/System/Flink/cloudlab/cloudlab.pem"
	if $isOfficial
	then
		numOfworkers=8
		serverList="nm cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
		slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
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
		ssh $username@$server "ssh $server 'sudo reboot'" &
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
			ssh $username@$server 'sudo rm -rf $HOME/.ssh/id_dsa*'
			scp ~/.ssh/id_dsa* $username@$server:~/.ssh/
		fi
		ssh $username@$server "cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys ;
		 chmod 0600 ~/.ssh/id_dsa*; 
		 chmod 0600 ~/.ssh/authorized_keys; 
		 rm -rf ~/.ssh/known_hosts; 	
		 echo 'StrictHostKeyChecking no' >> ~/.ssh/config"
#		ssh $username@$server "echo password less from localhost to $server"
	done	
fi

if $isAddToGroup
then
	for server in $serverList; do
		ssh $username@$server "sudo addgroup $groupname;sudo adduser $username $groupname;	sudo adduser root $groupname" &
		#ssh $username@$server "sudo adduser root $groupname" &
		
		#ssh $username@$server "sudo adduser $username sudo"
		#sudo adduser --ingroup $groupname $username;
	done
	wait
fi

if $isPasswordlessSSH
then
	passwordlessSSH () { echo $1 to $2;	ssh $username@$1 "ssh $2 'echo test passwordless SSH'" ;}
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
	installPackages () {
		#ssh $username@$1 'yes Y | sudo apt-get install openjdk-8-jdk'
		ssh $username@$1 'sudo apt-get purge -y openjdk*
			sudo apt-get purge -y oracle-java*
			sudo apt-get install -y software-properties-common			
			sudo add-apt-repository ppa:webupd8team/java
			sudo apt-get update
			sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections	
			sudo apt-get install -y oracle-java7-installer'
		ssh $username@$1 "sudo apt-get install -y cgroup-tools; sudo apt-get install -y scala;"	
	}
	echo "TODO: install JAVA"
	for server in $serverList; do
		installPackages $server &
	done
	wait
	echo ################################ install screen #####################################
	ssh $username@$masterNode "sudo apt-get install -y screen"
	
fi


if $isInstallGanglia
then
echo ################################# install Ganglia ###################################
	echo "Configure Ganglia master node $masterNode"
	ssh $username@$masterNode 'yes Y | sudo apt-get purge ganglia-monitor gmetad'
	### PLZ manually install Ganglia as we need to respond to some pop-ups
	# we may restart the Apache2 twice
	#ssh $username@$masterNode 'sudo apt-get install -y rrdtool  ganglia-webfrontend'
	ssh $username@$masterNode 'sudo apt-get install -y ganglia-monitor gmetad'
	
	# 
	ssh $username@$masterNode "sudo cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf ;
	sudo sed -i -e 's/data_source \"my cluster\" localhost/data_source \"sbu flink\" 1 localhost/g' /etc/ganglia/gmetad.conf;
	sudo sed -i -e 's/name = \"unspecified\"/name = \"sbu flink\"/g' /etc/ganglia/gmond.conf ;
	sudo sed -i -e 's/mcast_join = 239.2.11.71/#mcast_join = 239.2.11.71/g' /etc/ganglia/gmond.conf;
	sudo sed -i -e 's/bind = 239.2.11.71/#bind = 239.2.11.71/g' /etc/ganglia/gmond.conf"
	ssh $username@$masterNode "sudo sed -i -e 's/udp_send_channel {/udp_send_channel { host=nm/g' /etc/ganglia/gmond.conf"
	
	installGangliaFunc(){
		ssh $username@$1 "yes Y | sudo apt-get purge ganglia-monitor;
		sudo apt-get install -y ganglia-monitor;
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
	ssh $username@$masterNode 'sudo service ganglia-monitor restart & sudo service gmetad restart & sudo service apache2 restart'
	for server in $slaveNodes; do
		ssh $username@$server 'sudo service ganglia-monitor restart' &
	done
	wait	
fi


#################################### Apache Flink ################################
if $shudownFlink
then
	ssh $masterNode "$flinkVer/bin/stop-cluster.sh"
	#ssh $masterNode "$hadoopFolder/bin/yarn application -kill appplication_id"
fi

if $isInstallFlink 
then 	
	installFlinkFunc () {
		if $isDownload
		then
		ssh $1 "sudo rm -rf $flinkTgz; wget $flinkDownloadLink >> log.txt"
		fi
		if $isExtract
		then
			ssh $1 "sudo rm -rf $flinkVer; tar -xvzf $flinkTgz >> log.txt"
		fi
		
		#Replace localhost with resourcemanager in conf/flink-conf.yaml (jobmanager.rpc.address)
		ssh $1 "sed -i -e 's/jobmanager.rpc.address: localhost/jobmanager.rpc.address: nm/g' $flinkVer/conf/flink-conf.yaml;
		sed -i -e 's/jobmanager.heap.mb: 256/taskmanager.heap.mb: 1024/g' $flinkVer/conf/flink-conf.yaml;		
		sed -i -e 's/taskmanager.heap.mb: 512/taskmanager.heap.mb: $yarnMaxMem/g' $flinkVer/conf/flink-conf.yaml;
		sed -i -e 's/# taskmanager.network.numberOfBuffers: 2048/taskmanager.network.numberOfBuffers: $numNetworkBuffers/g' $flinkVer/conf/flink-conf.yaml"
		#sed -i -e 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: $yarnVcores/g' $flinkVer/conf/flink-conf.yaml;

		#Add hostnames of all worker nodes to the slaves file flinkVer/conf/slaves"
		ssh $1 "sudo rm -rf $flinkVer/conf/slaves"
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



##################### Hadoop############################


if $isShutDownHadoop
then
	echo shutdown Hadoop and Yarn
	ssh $username@$masterNode "$hadoopFolder/sbin/stop-dfs.sh;
	$hadoopFolder/sbin/stop-yarn.sh"
#	$hadoopFolder/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop proxyserver"
#	ssh $username@$masterNode "$hadoopFolder/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver"
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
				ssh $username@$1 "sudo rm -rf $hadoopTgz; wget $hadoopLink >> log.txt"
			fi
			if $isExtract
			then 
				echo extract $hadoopTgz
				ssh $username@$1 "rm -rf $hadoopVer; rm -rf $hadoopFolder; tar -xvzf $hadoopTgz >> log.txt; mv $hadoopVer $hadoopFolder"	
 				ssh $username@$1 "mkdir $hadoopFolder/conf"
			fi
			# add JAVA_HOME
			echo Configure Hadoop at $1
			ssh $username@$1 "echo export JAVA_HOME=$java_home > temp.txt"			
			ssh $username@$1 "cat temp.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh > temp2.txt ; mv temp2.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh"

			if $isInitPath
			then	
				ssh $username@$1 "echo export JAVA_HOME=$java_home >> .bashrc"				
				# Administrators can configure individual daemons using the configuration options shown below in the table:	
				#ssh $username@$1 'echo export HADOOP_NAMENODE_OPTS="-XX:+UseParallelGC" > temp.txt'
				#ssh $username@$1 "cat /$hadoopFolder/$configFolder/hadoop-env.sh temp.txt > temp2.txt; mv temp2.txt /$hadoopFolder/$configFolder/hadoop-env.sh"
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
				# ssh $username@$1 "sed -i -e 's/#export HADOOP_HEAPSIZE=/export HADOOP_HEAPSIZE=4096/g' $hadoopFolder/$configFolder/hadoop-env.sh"
				# YARN_HEAPSIZE
				# ssh $username@$server "sed -i -e 's/# YARN_HEAPSIZE=1000/# YARN_HEAPSIZE=4096/g' $hadoopFolder/$configFolder/yarn-env.sh"
			
				# configure HADOOP_PREFIX 
				ssh $username@$1 "echo export HADOOP_PREFIX=~/$hadoopFolder >> .bashrc;
				echo export HADOOP_YARN_HOME=~/$hadoopFolder >> .bashrc;
				echo export HADOOP_HOME=~/$hadoopFolder >> .bashrc;				
				echo export HADOOP_CONF_DIR=~/$hadoopFolder/$configFolder >> .bashrc;
				echo export YARN_CONF_DIR=~/$hadoopFolder/$configFolder >> .bashrc; 
				source .bashrc"
				
			fi

			# etc/hadoop/core-site.xml
			ssh $username@$1 "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"

			ssh $username@$1 "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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

</configuration>' > $hadoopFolder/etc/hadoop/core-site.xml"

			# etc/hadoop/hdfs-site.xml
			ssh $username@$1 "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?> 
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

</configuration>' > $hadoopFolder/$configFolder/hdfs-site.xml"

			echo Configure Yarn at $1

			# etc/hadoop/yarn-site.xml
			## Configurations for ResourceManager and NodeManager:

#			ssh $username@$1 "sudo rm -rf $yarnAppLogs; sudo mkdir $yarnAppLogs; sudo chmod 777 $yarnAppLogs"
			
hostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"
			ssh $username@$1 "echo '<?xml version=\"1.0\"?>
<configuration>

  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>$hostname</value>
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
    <name>yarn.scheduler.fair.preemption</name>
    <value>true</value>
  </property>
  
  <property>
    <name>yarn.scheduler.fair.preemption.cluster-utilization-threshold</name>
    <value>0.5</value>
  </property>

<!-- preemption & spark -->

  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle,spark_shuffle</value>
  </property>

  <property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>

  <property>
    <name>yarn.nodemanager.aux-services.spark_shuffle.class</name>
    <value>org.apache.spark.network.yarn.YarnShuffleService</value>
  </property>

  <property>
    <name>yarn.nodemanager.log-dirs</name>
    <value>$yarnAppLogs</value>
  </property>

<!--
  <property>
    <name>yarn.nodemanager.local-dirs</name>
    <value>$yarnAppLogs/local-dirs</value>
  </property> 
-->

  <property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>1024</value>
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
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>$yarnNodeMem</value>
  </property>
	
<!-- CGroups -->

<!--	
	<property>
		 <name>yarn.nodemanager.resource.percentage-physical-cpu-limit</name>
		 <value>100</value>
	</property>

	<property>
		 <name>yarn.nodemanager.linux-container-executor.cgroups.strict-resource-usage</name>
		 <value>true</value>
		<description>default is false that does not allows to use more than CPU</description>
	</property>

	<property>
	    <name>yarn.nodemanager.container-executor.class</name>
	    <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor</value>
	</property>
	<property>
	    <name>yarn.nodemanager.linux-container-executor.resources-handler.class</name>
	    <value>org.apache.hadoop.yarn.server.nodemanager.util.CgroupsLCEResourcesHandler</value>
	</property>

	<property>
	    <name>yarn.nodemanager.linux-container-executor.group</name>
	    <value>$groupname</value>
	</property> 

	<property>
	    <name>yarn.nodemanager.linux-container-executor.cgroups.mount</name>
	    <value>true</value>
	</property>
	<property>
	    <name>yarn.nodemanager.linux-container-executor.cgroups.mount-path</name>
	    <value>/sys/fs/cgroup</value>
	</property>
	<property>
	    <name>yarn.nodemanager.linux-container-executor.cgroups.hierarchy</name>
	    <value>/hadoop-yarn</value> 		
	</property>	
	
	<property>
		<name>yarn.nodemanager.linux-container-executor.nonsecure-mode.limit-users</name>
		<value>false</value>
	</property> 	

	<property>
		<name>yarn.nodemanager.linux-container-executor.nonsecure-mode.local-user</name>
		<value>$groupname</value>
	</property> 
-->



</configuration>' > $hadoopFolder/$configFolder/yarn-site.xml"


#yarn.nodemanager.linux-container-executor.group=#configured value of yarn.nodemanager.linux-container-executor.group
#allowed.system.users=##comma separated list of system users who CAN run applications
#			ssh $username@$1 "sudo sed -i -e 's/yarn.nodemanager.linux-container-executor.group=#/yarn.nodemanager.linux-container-executor.group=$groupname#/g' $hadoopFolder/$configFolder/container-executor.cfg"
#			ssh $username@$1 "sudo chown root:$groupname $hadoopFolder/$configFolder/container-executor.cfg"
#			ssh $username@$1 "sudo chown root:$groupname $hadoopFolder/bin/container-executor"
#			ssh $username@$1 "sudo chmod 6050 $hadoopFolder/bin/container-executor"
#			ssh $username@$1 "sudo mkdir $cgroupYarn"
#			ssh $username@$1 "sudo chmod -R 777 $cgroupYarn"			
#			ssh $username@$1 "cgdelete cpu:yarn"

# setup scheduler https://hadoop.apache.org/docs/r2.7.1/hadoop-yarn/hadoop-yarn-site/FairScheduler.html
			ssh $username@$1 "echo '<?xml version=\"1.0\"?>
<allocations>

<!--
<queue name=\"sls_queue_1\">
<minResources>1024 mb, 1 vcores</minResources>
<schedulingPolicy>fair</schedulingPolicy>
<weight>1</weight>
</queue>
<queue name=\"sls_queue_2\">
<minResources>1024 mb, 1 vcores</minResources>
<schedulingPolicy>drf</schedulingPolicy>
<weight>1</weight>
</queue>

<queue name=\"sls_queue_3\">
<minResources>1024 mb, 1 vcores</minResources>
<schedulingPolicy>fair</schedulingPolicy>
<weight>1</weight>
</queue>

<queue name=\"sls_queue_4\">
<minResources>1024 mb, 1 vcores</minResources>
<schedulingPolicy>fair</schedulingPolicy>
<weight>1</weight>
</queue>	
-->

<defaultQueueSchedulingPolicy>drf</defaultQueueSchedulingPolicy>
<defaultMinSharePreemptionTimeout>10</defaultMinSharePreemptionTimeout>
<defaultFairSharePreemptionTimeout>10</defaultFairSharePreemptionTimeout>
<defaultFairSharePreemptionThreshold>1.0</defaultFairSharePreemptionThreshold>

</allocations>' > $fairSchedulerFile"

			ssh $username@$1 "echo '<?xml version=\"1.0\"?>
<configuration>
  <property>
    <name>yarn.scheduler.capacity.resource-calculator</name>
    <value>org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator</value>
    <description>Default allocator</description>
  </property>
<!--
  <property>
    <name>yarn.scheduler.capacity.resource-calculator</name>
    <value>org.apache.hadoop.yarn.util.resource.DominantResourceCalculator</value>
    <description>DRF resource allocator</description>
  </property>
-->
  <property>
    <name>yarn.scheduler.capacity.root.queues</name>
    <value>sls_queue_1,sls_queue_2</value>
    <description>The queues at the this level (root is the root queue).
    </description>
  </property>
  
  <property>
    <name>yarn.scheduler.capacity.root.sls_queue_1.capacity</name>
    <value>50</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.sls_queue_1.maximum-capacity</name>
    <value>100</value>
  </property>
  
  <property>
    <name>yarn.scheduler.capacity.root.sls_queue_2.capacity</name>
    <value>50</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.sls_queue_2.maximum-capacity</name>
    <value>100</value>
  </property>

</configuration>' > $capacitySchedulerFile"
		
			# etc/hadoop/mapred-site.xml
			ssh $username@$1 "echo '<?xml version=\"1.0\"?>
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

</configuration>' > $hadoopFolder/$configFolder/mapred-site.xml"
			
			
			# monitoring script in etc/hadoop/yarn-site.xml

			# slaves etc/hadoop/slaves
			ssh $username@$1 "sudo rm -rf $hadoopFolder/$configFolder/slaves"
			for svr in $slaveNodes; do			
				ssh $username@$1 "echo $svr >> $hadoopFolder/$configFolder/slaves"
			done	
			#ssh $username@$1 "sudo chown -R $username:$groupname $hadoopFolder"
			
}
		for server in $serverList; do
			installHadoopFunc $server &
		done

		wait				
	fi
fi



#################################### Spark #####################################
if $shudownSpark
then
	ssh $masterNode "~/spark/bin/stop-all.sh"
fi


if $isInstallSpark 
then 	
	echo "#################################### Setup Spark #####################################"	
	installSparkFunc () {
		if $isDownload
		then
			ssh $1 "sudo rm -rf $sparkTgz; wget $sparkDownloadLink >> log.txt"
		fi
		if $isExtract
		then			
			ssh $1 "rm -rf $sparkFolder; tar -xvzf $sparkTgz >> log.txt; mv $sparkTgzFolder $sparkFolder"
		fi

		ssh $1 "echo 'export SPARK_DIST_CLASSPATH=~/$hadoopFolder/bin/hadoop
#export SPARK_JAVA_OPTS=-Dspark.driver.port=53411
export HADOOP_CONF_DIR=$hadoopFolder/$configFolder
export SPARK_MASTER_IP=$masterNode' > $sparkFolder/conf/spark-env.sh"

		ssh $1 "echo '
spark.dynamicAllocation.enabled true
spark.shuffle.service.enabled true
spark.executor.cores 1
#spark.dynamicAllocation.executorIdleTimeout 1s
#spark.dynamicAllocation.maxExecutors 9
#spark.dynamicAllocation.minExecutors 0

#spark.scheduler.maxRegisteredResourcesWaitingTime 30s #time for waiting for resouces
#spark.speculation false #one or more tasks are running slowly in a stage, they will be re-launched

spark.shuffle.service.port 7338
spark.scheduler.mode FAIR ' > $sparkFolder/conf/spark-defaults.conf"

		#Create /opt/spark-ver/conf/slaves add all the hostnames of spark slave nodes to it.
		ssh $1 "sudo rm -rf $sparkFolder/conf/slaves"
		for slave in $slaveNodes; do
			ssh $1 "echo $slave >> $sparkFolder/conf/slaves"
		done
	}
	for server in $serverList; do
		installSparkFunc $server &
		ssh $server "cp ~/spark/lib/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/" &
	done
	wait
		
fi


########################## restart all #########################

if $restartHadoop
then
	# shutdown all before starting.
	echo "============================stopping Hadoop (HDFS) and Yarn ========================="
	ssh $username@$masterNode "$hadoopFolder/sbin/stop-dfs.sh; $hadoopFolder/sbin/stop-yarn.sh"
	echo '============================ starting Hadoop==================================='

	if $isFormatHDFS
	then
		ssh $username@$masterNode "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
		ssh $username@$masterNode "yes Y | $hadoopFolder/bin/hdfs namenode -format HDFS4Flink"
	fi
	ssh $username@$masterNode "$hadoopFolder/sbin/start-dfs.sh"
	echo '============================ starting Yarn==================================='
	# operating YARN
	ssh $username@$masterNode "$hadoopFolder/sbin/start-yarn.sh"
	# operating MapReduce
	#ssh $username@$masterNode '$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver'	
fi

if $isInstallSpark 
then 
	echo "#################################### start Spark #####################################"		
	ssh $masterNode "~/spark/sbin/stop-all.sh; ~/spark/sbin/start-all.sh;"
fi


############################################### TEST CASES ###########################################
# upload test cases
if $isUploadTestCase 
then 
	cd $flinkSrc	
	rm -rf test/wordcount/*.txt test/wordcount/*.out test/wordcount/*.log
	tar zcvf test.tar $testCase
	ssh $username@$masterNode 'rm -rf test*'
	scp test.tar $username@$masterNode:~/ 
	ssh $username@$masterNode 'tar -xvzf test.tar'

	rm -rf test.tar
fi