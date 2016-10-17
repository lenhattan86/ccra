#!/bin/bash

## author: Tan N. Le ~ CS department Stony Brook University

### DO this command first at master node #####

# $sudo apt-get install -y rrdtool  ganglia-webfrontend

######################### System Variables #####################

isCloudLab=true
isAmazonEC=false
username="tanle"
groupname="yarnrm-PG0"

java_home='/usr/lib/jvm/java-7-oracle'

echo "=====set up $hostname====="

######################### Hadoop  #####################
hadoopFolder="hadoop"
configFolder="etc/hadoop"

hadoopVer="hadoop-2.7.2"
hadoopLink="http://apache.claz.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz"
hadoopTgz="hadoop-2.7.2.tar.gz"
#hadoopTgz="hadoop-2.7.2-max.tar.gz"

#hadoopVer="hadoop-2.6.4"
#hadoopLink="http://apache.claz.org/hadoop/common/hadoop-2.6.4/hadoop-2.6.4.tar.gz"
#hadoopTgz="hadoop-2.6.4.tar.gz"

#hadoopVer="hadoop-2.6.3"
#hadoopLink="http://apache.claz.org/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz"
#hadoopTgz="hadoop-2.6.3.tar.gz"

yarnVcores=4
vmemRatio=4
#yarnNodeMem=131072 # 128 GB
#yarnNodeMem=65536 # 64 GB
yarnNodeMem=$((2*$yarnVcores*1024)) # 2 times of number of vcores
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

shedulingPolicy="SpeedFair"; weight=1

hdfsDir="/dev/hdfs"
#hdfsDir="/users/tanle/hdfs"
#hdfsDir="/proj/yarnrm-PG0/hdfs"

#yarnAppLogs="/dev/yarn-logs"
yarnAppLogs="/dev/shm/yarn-logs" # only used in hadoop 2.7
#yarnAppLogs="/users/$username/yarn-logs" # for hadoop 2.6

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

#sparkVer="spark-1.6.1"
#sparkTgz="spark-1.6.1-bin-hadoop2.6.tgz"
#sparkTgzFolder="spark-1.6.1-bin-hadoop2.6"
#sparkDownloadLink="http://apache.claz.org/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz"

sparkVer="spark-2.0.0-preview"
sparkTgz="spark-2.0.0-preview-bin-hadoop2.7.tgz"
sparkTgzFolder="spark-2.0.0-preview-bin-hadoop2.7"
sparkDownloadLink="https://dist.apache.org/repos/dist/release/spark/spark-2.0.0-preview/spark-2.0.0-preview-bin-hadoop2.7.tgz"

##########

IS_INIT=false

echo "setup $hostname"

REBOOT=false
isOfficial=false
isSingleNodeCluster=false	
isUploadTestCase=false

isUploadYarn=true
isDownload=false
isExtract=true

hostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"; shedulingPolicy="SpeedFair"; cp ~/.ssh/config.yarn-perf ~/.ssh/config; 
#hostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"; shedulingPolicy="drf"; cp ~/.ssh/config.yarn-drf ~/.ssh/config; isUploadYarn=true ; 

customizedHadoopPath="/home/tanle/projects/ccra/hadoop/hadoop-dist/target/$hadoopTgz"

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

isInstallSpark=false
isModifySpark=false
startSparkYarn=false
shudownSpark=false

if $IS_INIT
then
	isDownload=true
	isUploadYarn=false ; shedulingPolicy="drf" # check with the stable version first.
	isExtract=true
	
	

	isUploadKey=true
#	isGenerateKey=false
	isPasswordlessSSH=true
	isAddToGroup=true

	isInstallBasePackages=true

	isInstallGanglia=false
	startGanglia=false

	isInstallHadoop=true
	isInitPath=true
	isFormatHDFS=true
	isShutDownHadoop=true
	restartHadoop=true

	isInstallFlink=false

	isInstallSpark=true

#	shedulingPolicy="drf"; weight=3
fi

if $isCloudLab
then
	masterNode="nm"
	clientNode="ctl"        
	if $isOfficial
	then
		numOfworkers=8
		serverList="nm ctl cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7"
		slaveNodes="ctl cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7"
		numOfReplication=1
	else
		numOfworkers=4
		serverList="nm ctl cp-1 cp-2 cp-3"
		slaveNodes="ctl cp-1 cp-2 cp-3"
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
	echo "Waiting for 15 mins for the cluster to be ready."
	sleep 900
fi

if $isUploadKey
then		
echo ################################# passwordless SSH ####################################
	if $isGenerateKey 
	then
            while true; do
            	read -p "Do you wish to generate new public keys ?" yn
            case $yn in
                [Yy]* ) 
			sudo rm -rf $HOME/.ssh/id_dsa*
			sudo rm -rf $HOME/.ssh/authorized_keys*
			yes Y | ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa	
			sudo chmod 600 $HOME/.ssh/id_dsa*
			echo 'StrictHostKeyChecking no' >> ~/.ssh/config
			break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done 	
		
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
	passwordlessSSH () { ssh $username@$1 "ssh $2 'echo test passwordless SSH: $1 to $2'" ;}
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
		ssh $username@$1 'sudo apt-get purge -y openjdk*
			sudo apt-get purge -y oracle-java*
			sudo apt-get install -y software-properties-common			
			sudo add-apt-repository ppa:webupd8team/java
			sudo apt-get update
			sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections	
			sudo apt-get install -y oracle-java7-installer'
		ssh $username@$1 "sudo apt-get install -y cgroup-tools; sudo apt-get install -y scala; sudo apt-get install -y vim"	
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
			echo Set up Hadoop at $1 step 0
			#if $isUploadYarn 
			#then
			#	ssh $username@$1 "sudo rm -rf $hadoopTgz"
			#	scp $customizedHadoopPath $username@$1:~/ 
			#fi
			if $isDownload
			then		
				echo downloading $hadoopVer		
				ssh $username@$1 "sudo rm -rf $hadoopTgz; wget $hadoopLink >> log.txt"
			fi

			if $isExtract
			then 
				echo extract $hadoopTgz
				ssh $username@$1 "rm -rf $hadoopVer; rm -rf $hadoopFolder; tar -xvzf $hadoopTgz >> log.txt; mv $hadoopVer $hadoopFolder; mkdir $hadoopFolder/conf"
			fi
			# add JAVA_HOME
			
			echo "copy SWIM config files for Facebook-trace simulation"
			scp ../SWIM/randomwriter_conf.xsl $1:~/hadoop/config
			scp ../SWIM/workGenKeyValue_conf.xsl $1:~/hadoop/config
			
			echo Configure Hadoop at $1 step 1
			ssh $username@$1 "echo export JAVA_HOME=$java_home > temp.txt; cat temp.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh > temp2.txt ; mv temp2.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh "

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
			echo Configure Hadoop at $1 step 2
			# etc/hadoop/core-site.xml
			ssh $username@$1 "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
			echo Configure Hadoop at $1 step 3
			sleep 2
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
				# HADOOP_NODE_OPTS
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
			# etc/hadoop/hdfs-site.xml
			echo Set up Hadoop at $1 step 4
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

			echo Configure Yarn at $1 step 0

			# etc/hadoop/yarn-site.xml
			## Configurations for ResourceManager and NodeManager:

			ssh $username@$1 "sudo rm -rf $yarnAppLogs; sudo mkdir $yarnAppLogs; sudo chmod 777 $yarnAppLogs"
			echo Configure Yarn at $1 step 1
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


<!-- preemption & spark -->


  <property>
    <name>yarn.scheduler.fair.preemption</name>
    <!--<value>true</value>-->
    <value>false</value>
  </property>
  
  <property>
    <name>yarn.scheduler.fair.preemption.cluster-utilization-threshold</name>
    <value>0.0</value>
  </property>

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
			echo Configure Yarn at $1 step 2
			ssh $username@$1 "echo '<?xml version=\"1.0\"?>
<allocations>

<defaultQueueSchedulingPolicy>$shedulingPolicy</defaultQueueSchedulingPolicy>
<defaultMinSharePreemptionTimeout>1</defaultMinSharePreemptionTimeout>
<defaultFairSharePreemptionTimeout>1</defaultFairSharePreemptionTimeout>
<defaultFairSharePreemptionThreshold>1.0</defaultFairSharePreemptionThreshold>

<queue name=\"interactive0\">	
	<!--<minReq>131072 mb, 64 vcores</minReq>-->
	<minReq>24576 mb, 12 vcores</minReq>
	<!-- <minReq>235520 mb, 115 vcores</minReq> -->
	<speedDuration>60000</speedDuration>
	<fairPriority>0.5</fairPriority>
	<period>120000</period>
	<weight>$weight</weight>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"interactive1\">	
	<!--<minReq>131072 mb, 64 vcores</minReq>-->
	<!-- <minReq>196608 mb, 96 vcores</minReq> -->
	<minReq>24576 mb, 12 vcores</minReq>
	<!-- <minReq>235520 mb, 115 vcores</minReq> -->
	<fairPriority>0.5</fairPriority>
	<speedDuration>60000</speedDuration>
	<period>120000</period>
	<weight>$weight</weight>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch0\">
	<weight>1</weight>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch1\">
	<weight>1</weight>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>

<!--
<queue name=\"interactive1\">
	<minReq>8192 mb,4 vcores</minReq>
</queue>

<queue name=\"interactive2\">
	<minReq>8192 mb,4 vcores</minReq>
</queue>

<queue name=\"interactive3\">
	<minReq>8192 mb,4 vcores</minReq>
</queue>

<queue name=\"batch\">
	<weight>1</weight>	
</queue>
-->

<queue name=\"tanle\">
	<weight>1</weight>
	<schedulingPolicy>fifo</schedulingPolicy>	
</queue>

</allocations>' > $fairSchedulerFile"
			echo Configure Yarn at $1 step 3
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
			echo Configure Yarn at $1 step 4
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
  <!-- increase max map tasks -->
  <property>
    <name>mapreduce.tasktracker.map.tasks.maximum</name>
    <value>15</value>
  </property>

  <property>
    <name>mapreduce.jobtracker.taskscheduler.maxrunningtasks.perjob</name>
    <value>14</value>
  </property>

  <property>
    <name>mapreduce.jobtracker.maxtasks.perjob</name>
    <value>13</value>
  </property>

  <property>
    <name>mapreduce.job.maps</name>
    <value>12</value>
  </property>

</configuration>' > $hadoopFolder/$configFolder/mapred-site.xml"
			
			
			# monitoring script in etc/hadoop/yarn-site.xml
			echo Configure Yarn at $1 step 5
			# slaves etc/hadoop/slaves
			ssh $username@$1 "sudo rm -rf $hadoopFolder/$configFolder/slaves"
			tempCMD=""
			for svr in $slaveNodes; do	
				tempCMD="$tempCMD echo $svr >> $hadoopFolder/$configFolder/slaves; "		
				#ssh $username@$1 "echo $svr >> $hadoopFolder/$configFolder/slaves"
			done
			ssh $username@$1 "$tempCMD"
			#ssh $username@$1 "sudo chown -R $username:$groupname $hadoopFolder"
			
}
		
		if $isUploadYarn 
		then
			# upload to the nm
			ssh $username@$masterNode "sudo rm -rf $hadoopTgz"
			scp $customizedHadoopPath $username@$masterNode:~/ 
			# share upload file among the workers.
			uploadCMD="echo 'multithread sharing....' "
			for slave in $slaveNodes; do
				ssh $username@$slave "sudo rm -rf $hadoopTgz"
				uploadCMD="$uploadCMD & scp $hadoopTgz $username@$slave:~/ "
				#ssh $username@$masterNode "scp $hadoopTgz $username@$slave:~/ "
			done
			#wait
			uploadCMD="$uploadCMD & wait"
			ssh $username@$masterNode "$uploadCMD"
			
		fi
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
spark.executor.memory 768m

spark.dynamicAllocation.enabled true
#spark.executor.instances 10000

spark.dynamicAllocation.executorIdleTimeout 5
spark.dynamicAllocation.schedulerBacklogTimeout 5
spark.dynamicAllocation.sustainedSchedulerBacklogTimeout 5
spark.dynamicAllocation.cachedExecutorIdleTimeout 900

spark.shuffle.service.enabled true
spark.shuffle.service.port 7338

spark.scheduler.mode FAIR

spark.task.maxFailures 999
spark.yarn.max.executor.failures 999

#spark.streaming.dynamicAllocation.enabled true
spark.streaming.dynamicAllocation.scalingUpRatio 0.0005
spark.streaming.dynamicAllocation.scalingDownRatio 0.0000001
spark.streaming.dynamicAllocation.minExecutors 1
spark.streaming.dynamicAllocation.maxExecutors 500' > $sparkFolder/conf/spark-defaults.conf"

		#Create /opt/spark-ver/conf/slaves add all the hostnames of spark slave nodes to it.
		ssh $1 "sudo rm -rf $sparkFolder/conf/slaves"
		for slave in $slaveNodes; do
			ssh $1 "echo $slave >> $sparkFolder/conf/slaves"
		done

		#ssh $1 "cp ~/spark/lib/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/ > .null.txt" 
		ssh $1 "cp ~/spark/yarn/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/" # for 2.0.0 version
	}
	for server in $serverList; do
		installSparkFunc $server &
	done
	wait
else
	for server in $serverList; do
		#ssh $server "cp ~/spark/lib/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/ > .null.txt" 
		ssh $server "cp ~/spark/yarn/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/" # for 2.0.0 version
	done	
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

echo ""
echo "[INFO] $hostname "
echo "[INFO] Finished at: $(date) "

