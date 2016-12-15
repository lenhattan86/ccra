#!/bin/bash

## constants
SPEEDFAIR="SpeedFair"
DRF="drf"
Strict="Strict"
DRFW="drf-w"
METHOD=$SPEEDFAIR

if [ -z "$2" ]
then
	METHOD=$SPEEDFAIR
else
	METHOD="$2"
fi

if [ -z "$3" ]
then
	batchNum=4
else
	batchNum=$3
fi

## author: Tan N. Le ~ CS department Stony Brook University

### DO this command first at master node #####

# $sudo apt-get install -y rrdtool  ganglia-webfrontend

######################### enviromental variables ##############

set|grep AUTOSSH
AUTOSSH_GATETIME=0
AUTOSSH_PORT=20000

######################### System Variables #####################

isCloudLab=true
isAmazonEC=false
isLocalhost=false
IS_INIT=false
isOfficial=true
TEST=false
SSH_CMD="autossh"
#SSH_CMD="ssh -v "
yarnFramework="yarn"
enableSim="true"
enablePreemption="false"
if $isOfficial
then
	scaleDown=1.0 # DEFAULT 1.0, use 4.0 to increase the number of tasks -> 4 times.
else
	scaleDown=4.0 # DEFAULT 1.0, use 4.0 to increase the number of tasks -> 4 times.
fi

if $isLocalhost
then
	isCloudLab=false
	isAmazonEC=false
	IS_INIT=false
	scaleDown=1.0
fi
username="tanle"
groupname="yarnrm-PG0"

workloadSrcFile="/home/tanle/projects/SpeedFairSim/input_gen/jobs_input_1_$batchNum.txt"
genJavaFile="/home/tanle/projects/ccra/SWIM/GenerateProfile.java"

java_home='/usr/lib/jvm/java-8-oracle'



######################### Hadoop  #####################
hadoopFolder="hadoop"
configFolder="etc/hadoop"
tezConfigFolder="etc/tez"

hadoopVersion="2.7.2.1"
hadoopFullVer="hadoop-$hadoopVersion"
hadoopLink="http://apache.claz.org/hadoop/common/hadoop-$hadoopVersion/hadoop-$hadoopVersion.tar.gz"
hadoopTgz="hadoop-$hadoopVersion.tar.gz"


if $isLocalhost
then
	workloadSrcFile="/home/tanle/projects/SpeedFairSim/workload/jobs_input_1_1_simple.txt"
	workloadFile="/home/tanle/hadoop/conf/simple.txt"
	profilePath="/home/tanle/hadoop/conf/"
	simLogPath="/home/tanle/SWIM/scriptsTest/workGenLogs/"
	genJavaFileDst="/home/tanle/hadoop/conf/GenerateProfile.java"
else
	workloadFile="/users/tanle/hadoop/conf/simple.txt"
	profilePath="/users/tanle/hadoop/conf/"
	simLogPath="/users/tanle/SWIM/scriptsTest/workGenLogs/"
	genJavaFileDst="/users/tanle/hadoop/conf/GenerateProfile.java"
fi

yarnVcores=32
if $isLocalhost
then
	yarnVcores=16
fi
vmemRatio=4
#yarnNodeMem=131072 # 128 GB
#yarnNodeMem=65536 # 64 GB
yarnNodeMem=$(($yarnVcores*1024)) # 2 times of number of vcores
#yarnNodeMem=32768 # 32 GB


yarnMaxMem=32768 # for each container
isCapacityScheduler=false
if $isLocalhost
then
	temp="/home/$username"
else
	temp="/users/$username"
fi
fairSchedulerFile="$temp/$hadoopFolder/etc/fair-scheduler.xml"
capacitySchedulerFile="$temp/$hadoopFolder/etc/capacity-scheduler.xml"
if $isCapacityScheduler
then
	schedulerFile=$capacitySchedulerFile
	scheduler="org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"
else
	schedulerFile=$fairSchedulerFile
	scheduler="org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler" 
fi

echo "METHOD: $METHOD"

if [ "$METHOD" == "$SPEEDFAIR" ];
then
        shedulingPolicy="SpeedFair"; weight=1
elif [ "$METHOD" == "$DRF" ];
then
	shedulingPolicy="drf"; weight=1
elif [ "$METHOD" == "$Strict" ];
then
	shedulingPolicy="drf"; weight=999999
elif [ "$METHOD" == "$DRFW" ];
then
	shedulingPolicy="drf"; weight=4
else
	echo "[ERROR] This METHOD $METHOD does not exist."; exit;
	shedulingPolicy="drf";
fi

echo $schedulingPolicy

hdfsDir="/dev/hdfs"
#hdfsDir="$temp/hdfs"
#hdfsDir="/proj/yarnrm-PG0/hdfs"

#yarnAppLogs="/dev/yarn-logs"
yarnAppLogs="/dev/shm/yarn-logs" # only used in hadoop 2.7
#yarnAppLogs="/users/$username/yarn-logs" # for hadoop 2.6

cgroupYarn="~/$hadoopFolder/cgroup"
numOfReplication=3


tezVersion="0.8.4"

tezTar="tez-$tezVersion.tar.gz"
tezMinTaz="tez-$tezVersion-minimal.tar.gz"
TEZ_JARS="$hadoopFolder/tez_jars"
TEZ_CONF_DIR="$hadoopFolder/$tezConfigFolder"

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

sparkVer="spark-2.0.2"
sparkTgz="spark-2.0.2-bin-hadoop2.7.tgz"
sparkTgzFolder="spark-2.0.2-bin-hadoop2.7"
if $isLocalhost
then
	sparkDownloadLink="http://mirror.navercorp.com/apache/spark/spark-2.0.2/spark-2.0.2-bin-hadoop2.7.tgz"
else
	sparkDownloadLink="http://d3kbcqa49mib13.cloudfront.net/spark-2.0.2-bin-hadoop2.7.tgz"
fi

##########

PARALLEL=41

if $isLocalhost
then
	hostname="localhost"; 
else

	if [ -z "$1" ]
	then
		#hostname="ctl.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"; cp ~/.ssh/config.yarn-perf ~/.ssh/config; 
		#hostname="ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us"; cp ~/.ssh/config.yarn-drf ~/.ssh/config; isUploadYarn=true ; 
		#hostname="ctl.yarn-small.yarnrm-pg0.wisc.cloudlab.us"; cp ~/.ssh/config.yarn-small ~/.ssh/config; 
		hostname="ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us"; cp ~/.ssh/config.yarn-large ~/.ssh/config; 
	else
		hostname="ctl.$1.yarnrm-pg0.utah.cloudlab.us"; cp ~/.ssh/config.$1 ~/.ssh/config; 
	fi
fi
echo "[INFO] =====set up $hostname====="

REBOOT=false

isUploadYarn=false
isDownload=false
isExtract=false

isInstallHadoop=true

isInstallTez=true
isUploadTez=true


if $isUploadYarn
then
	isExtract=true
elif $isDownload
then
	isExtract=true
fi

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


isInitPath=false
if $isDownload
then
	isInitPath=true
fi
isModifyHadoop=false
isShutDownHadoop=false
restartHadoop=false
isFormatHDFS=false



isInstallFlink=false
isModifyFlink=false
startFlinkYarn=false
shudownFlink=false
startFlinkStandalone=false # not necessary

isInstallSpark=false
isModifySpark=false
startSparkYarn=false
shudownSpark=false


if $isInstallTez
then
	yarnFramework="yarn-tez"
fi

if $isInstallHadoop
then
	isShutDownHadoop=true
	restartHadoop=true
	isFormatHDFS=true
fi

if $isInstallSpark
then
	shuffleStr="mapreduce_shuffle,spark_shuffle"
else
	shuffleStr="mapreduce_shuffle"
fi


if $IS_INIT
then
	#shedulingPolicy="drf"
	isDownload=false
	isUploadYarn=true
	isExtract=true

	isUploadKey=true
	isGenerateKey=false
	isPasswordlessSSH=true
	isAddToGroup=false

	isInstallBasePackages=true

	isInstallGanglia=false
	startGanglia=false

	isInstallHadoop=true
	isInitPath=true
	isFormatHDFS=true
	isShutDownHadoop=true
	restartHadoop=true

	isInstallFlink=false

	isInstallSpark=false

	isInstallTez=true
	isUploadTez=true
fi

if $isLocalhost
then
	echo "Setup Yarn on localhost"
	masterNode="localhost"
	serverList="localhost"
	slaveNodes="localhost"
	numOfReplication=1
	numOfworkers=1
	isUploadKey=false
	isInstallBasePackages=false
	isInstallGanglia=false
	isInstallFlink=false
	isAddToGroup=false
	isInitPath=false # use it if working on the new computer

	isDownload=false
	isUploadYarn=true
	isExtract=true

	isInstallTez=true
	isUploadTez=true
elif $isCloudLab
then
	echo " at CLOUDLAB "
	masterNode="ctl"
	if $isOfficial
	then
		numOfworkers=40
		serverList="$masterNode cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-14 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-28 cp-29 cp-30 cp-31 cp-32 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40"
		#serverList="$masterNode cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13     cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27   cp-29 cp-30 cp-31   cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40 cp-41 cp-42"
		slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-14 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-28 cp-29 cp-30 cp-31 cp-32 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40"
		numOfReplication=3
	else
		if $TEST
		then
			numOfworkers=1
			serverList="$masterNode cp-1"
			slaveNodes="cp-1"
			numOfReplication=1

		else
			numOfworkers=8
			serverList="$masterNode cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
			slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
			numOfReplication=3
		fi
	fi
elif $isAmazonEC
then
	echo "Amazon EC"
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
		$SSH_CMD $username@$server "ssh $server 'sudo reboot'" &
	done
	wait
	echo "Waiting for 15 mins for the cluster to be ready."
	sleep 900
fi

echo ####################### TEST CLUSTER NETWORK ##########################
for server in $serverList; do
	$SSH_CMD $username@$server " echo Hello $server " &
done
wait

if $isUploadKey
then		
echo ################################# passwordless SSH ####################################
	if $isGenerateKey 
	then
            while true; do
            	read -p "Do you wish to generate new public keys ?" yn
            case $yn in
                [Yy]* ) 
			sudo rm -rf $HOME/.ssh/id_rsa*
			sudo rm -rf $HOME/.ssh/authorized_keys*
			yes Y | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa	
			cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
			sudo chmod 0600 $HOME/.ssh/id_rsa*
			sudo chmod 0600 ~/.ssh/authorized_keys
			echo 'StrictHostKeyChecking no' >> ~/.ssh/config
			break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
	    done 	
		
	fi
	uploadKeys () { 
		echo upload keys to $1
		$SSH_CMD $username@$1 'sudo rm -rf $HOME/.ssh/id_rsa*'
		scp ~/.ssh/id_rsa* $username@$1:~/.ssh/
		$SSH_CMD $username@$1 "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys ;
		 chmod 0600 ~/.ssh/id_rsa*; 
		 chmod 0600 ~/.ssh/authorized_keys; 
		 rm -rf ~/.ssh/known_hosts; 	
		 echo 'StrictHostKeyChecking no' >> ~/.ssh/config"
	}
	rm -rf ~/.ssh/known_hosts

	echo "uploading keys"
	for server in $serverList; do
		uploadKeys $server &
	done	
	wait
fi

if $isAddToGroup
then
	for server in $serverList; do
		$SSH_CMD $username@$server "sudo addgroup $groupname;sudo adduser $username $groupname;	sudo adduser root $groupname" &
	done
	wait
fi

if $isPasswordlessSSH
then
	passwordlessSSH () { 
		echo "test ssh from $1 to $2"
		ssh $username@$1 "ssh $2 'echo test passwordless SSH: $1 to $2'" ;
	}
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
		$SSH_CMD $username@$1 "sudo apt-get -y install $SSH_CMD
			sudo apt-get purge -y openjdk*
			sudo apt-get purge -y oracle-java*
			sudo apt-get install -y software-properties-common			
			yes='' | sudo add-apt-repository ppa:webupd8team/java
			sudo apt-get update
			sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections	
			sudo apt-get install -y oracle-java8-installer"
		$SSH_CMD $username@$1 "sudo apt-get install -y cgroup-tools; sudo apt-get install -y scala; sudo apt-get install -y vim"	
	}
	echo "TODO: install JAVA"
	counter=0;
	for server in $serverList; do
		counter=$((counter+1))
		installPackages $server &		
		if [[ "$counter" -gt $PARALLEL ]]; then
	       		counter=0;
			wait
	       	fi		
	done
	wait
	echo ################################ install screen #####################################
	$SSH_CMD $username@$masterNode "sudo apt-get install -y screen"
	
fi


if $isInstallGanglia
then
echo ################################# install Ganglia ###################################
	echo "Configure Ganglia master node $masterNode"
	$SSH_CMD $username@$masterNode 'yes Y | sudo apt-get purge ganglia-monitor gmetad'
	### PLZ manually install Ganglia as we need to respond to some pop-ups
	# we may restart the Apache2 twice
	#$SSH_CMD $username@$masterNode 'sudo apt-get install -y rrdtool  ganglia-webfrontend'
	$SSH_CMD $username@$masterNode 'sudo apt-get install -y ganglia-monitor gmetad'
	
	# 
	$SSH_CMD $username@$masterNode "sudo cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf ;
	sudo sed -i -e 's/data_source \"my cluster\" localhost/data_source \"sbu flink\" 1 localhost/g' /etc/ganglia/gmetad.conf;
	sudo sed -i -e 's/name = \"unspecified\"/name = \"sbu flink\"/g' /etc/ganglia/gmond.conf ;
	sudo sed -i -e 's/mcast_join = 239.2.11.71/#mcast_join = 239.2.11.71/g' /etc/ganglia/gmond.conf;
	sudo sed -i -e 's/bind = 239.2.11.71/#bind = 239.2.11.71/g' /etc/ganglia/gmond.conf"
	$SSH_CMD $username@$masterNode "sudo sed -i -e 's/udp_send_channel {/udp_send_channel { host=$masterNode/g' /etc/ganglia/gmond.conf"
	
	installGangliaFunc(){
		$SSH_CMD $username@$1 "yes Y | sudo apt-get purge ganglia-monitor;
		sudo apt-get install -y ganglia-monitor;
		sudo sed -i -e 's/name = \"unspecified\"/name = \"sbu flink\"/g' /etc/ganglia/gmond.conf;
		sudo sed -i -e 's/mcast_join = 239.2.11.71/#mcast_join = 239.2.11.71/g' /etc/ganglia/gmond.conf;
		sudo sed -i -e 's/udp_send_channel {/udp_send_channel { host=$masterNode/g' /etc/ganglia/gmond.conf"
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
	$SSH_CMD $username@$masterNode 'sudo service ganglia-monitor restart & sudo service gmetad restart & sudo service apache2 restart'
	for server in $slaveNodes; do
		$SSH_CMD $username@$server 'sudo service ganglia-monitor restart' &
	done
	wait	
fi


#################################### Apache Flink ################################
if $shudownFlink
then
	$SSH_CMD $masterNode "$flinkVer/bin/stop-cluster.sh"
	#ssh $masterNode "$hadoopFolder/bin/yarn application -kill appplication_id"
fi

if $isInstallFlink 
then 	
	installFlinkFunc () {
		if $isDownload
		then
		$SSH_CMD $1 "sudo rm -rf $flinkTgz; wget $flinkDownloadLink >> log.txt"
		fi
		if $isExtract
		then
			$SSH_CMD $1 "sudo rm -rf $flinkVer; tar -xvzf $flinkTgz >> log.txt"
		fi
		
		#Replace localhost with resourcemanager in conf/flink-conf.yaml (jobmanager.rpc.address)
		$SSH_CMD $1 "sed -i -e 's/jobmanager.rpc.address: localhost/jobmanager.rpc.address: $masterNode/g' $flinkVer/conf/flink-conf.yaml;
		sed -i -e 's/jobmanager.heap.mb: 256/taskmanager.heap.mb: 1024/g' $flinkVer/conf/flink-conf.yaml;		
		sed -i -e 's/taskmanager.heap.mb: 512/taskmanager.heap.mb: $yarnMaxMem/g' $flinkVer/conf/flink-conf.yaml;
		sed -i -e 's/# taskmanager.network.numberOfBuffers: 2048/taskmanager.network.numberOfBuffers: $numNetworkBuffers/g' $flinkVer/conf/flink-conf.yaml"
		#sed -i -e 's/taskmanager.numberOfTaskSlots: 1/taskmanager.numberOfTaskSlots: $yarnVcores/g' $flinkVer/conf/flink-conf.yaml;

		#Add hostnames of all worker nodes to the slaves file flinkVer/conf/slaves"
		$SSH_CMD $1 "sudo rm -rf $flinkVer/conf/slaves"
		for slave in $slaveNodes; do
			$SSH_CMD $1 "echo $slave >> $flinkVer/conf/slaves"
		done	
	}
	for server in $serverList; do
		installFlinkFunc $server &
	done
	wait
fi


if $startFlinkStandalone	
then
	$SSH_CMD $masterNode "$flinkVer/bin/stop-cluster.sh"
	$SSH_CMD $masterNode "$flinkVer/bin/start-cluster.sh"
fi	



##################### Hadoop############################


if $isShutDownHadoop
then
	echo shutdown Hadoop and Yarn
	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/stop-dfs.sh;
	$hadoopFolder/sbin/stop-yarn.sh"
#	$hadoopFolder/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop proxyserver"
#	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver"
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
			echo Configure up Hadoop at $1 step 0
			if $isUploadYarn 
			then
			#	$SSH_CMD $username@$1 "sudo rm -rf $hadoopTgz"
			#	scp $customizedHadoopPath $username@$1:~/ 
				echo already uploaded Yarn onto $1
			elif $isDownload
			then		
				echo downloading $hadoopTgz		
				$SSH_CMD $username@$1 "sudo rm -rf $hadoopTgz; wget $hadoopLink >> log.txt"
			fi
#			sleep 3
			if $isExtract
			then 
				echo extract $hadoopTgz
				$SSH_CMD $username@$1 "rm -rf $hadoopFullVer; rm -rf $hadoopFolder; tar -xvzf $hadoopTgz >> log.txt; mv $hadoopFullVer $hadoopFolder; mkdir $hadoopFolder/conf"
				# add JAVA_HOME
				
				# "copy SWIM config files for Facebook-trace simulation"
				scp ../SWIM/randomwriter_conf.xsl $1:~/hadoop/config
				scp ../SWIM/workGenKeyValue_conf.xsl $1:~/hadoop/config
			
				echo Configure Hadoop at $1 step 1
				
				$SSH_CMD $username@$1 "echo export JAVA_HOME=$java_home > temp.txt; cat temp.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh > temp2.txt ; mv temp2.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh "
				# for Tez
				$SSH_CMD $username@$1 "echo export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/* > temp.txt; cat temp.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh > temp2.txt ; mv temp2.txt ~/$hadoopFolder/$configFolder/hadoop-env.sh "
			fi
			
			echo Configure Hadoop at $1 step 2
			# etc/hadoop/core-site.xml
			$SSH_CMD $username@$1 "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
			echo Configure Hadoop at $1 step 3 core-site.xml
			#sleep 2
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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
				# $SSH_CMD $username@$1 "sed -i -e 's/#export HADOOP_HEAPSIZE=/export HADOOP_HEAPSIZE=4096/g' $hadoopFolder/$configFolder/hadoop-env.sh"
				# YARN_HEAPSIZE
			# etc/hadoop/hdfs-site.xml
			echo Configure Hadoop at $1 step 4 hdfs-site.xml
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?> 
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

			$SSH_CMD $username@$1 "sudo rm -rf $yarnAppLogs; sudo mkdir $yarnAppLogs; sudo chmod 777 $yarnAppLogs"

			echo Configure Yarn at $1 step 1 yarn-site.xml
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\"?>
<configuration>

  <property>
    <name>tez.simulation.enabled</name>
    <value>$enableSim</value>
  </property>

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
    <name>yarn.scheduler.fair.update-interval-ms</name>
    <value>100</value>
  </property>

<!-- preemption & spark -->

  <property>
    <name>yarn.scheduler.fair.preemption</name>
    <value>$enablePreemption</value>
  </property>

  <property>
    <name>yarn.scheduler.fair.preemptionInterval</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.fair.waitTimeBeforeKill</name>
    <value>100</value>
  </property>
  
  <property>
    <name>yarn.scheduler.fair.preemption.cluster-utilization-threshold</name>
    <value>0.8</value>
  </property>

  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>$shuffleStr</value>
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

  <property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>1024</value>
  </property>
	
  <property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>$yarnMaxMem</value>
  </property>

  <property>
    <name>yarn.scheduler.maximum-allocation-vcores</name>
    <value>$yarnVcores</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>$yarnVcores</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>$yarnNodeMem</value>
  </property>

  <property>
    <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
  </property>

  <property>
    <name>yarn.cmpl.path</name>
    <value>$simLogPath</value>
  </property>
	
</configuration>' > $hadoopFolder/$configFolder/yarn-site.xml"


#yarn.nodemanager.linux-container-executor.group=#configured value of yarn.nodemanager.linux-container-executor.group
#allowed.system.users=##comma separated list of system users who CAN run applications
#			$SSH_CMD $username@$1 "sudo sed -i -e 's/yarn.nodemanager.linux-container-executor.group=#/yarn.nodemanager.linux-container-executor.group=$groupname#/g' $hadoopFolder/$configFolder/container-executor.cfg"
#			$SSH_CMD $username@$1 "sudo chown root:$groupname $hadoopFolder/$configFolder/container-executor.cfg"
#			$SSH_CMD $username@$1 "sudo chown root:$groupname $hadoopFolder/bin/container-executor"
#			$SSH_CMD $username@$1 "sudo chmod 6050 $hadoopFolder/bin/container-executor"
#			$SSH_CMD $username@$1 "sudo mkdir $cgroupYarn"
#			$SSH_CMD $username@$1 "sudo chmod -R 777 $cgroupYarn"			
#			$SSH_CMD $username@$1 "cgdelete cpu:yarn"

# setup scheduler https://hadoop.apache.org/docs/r2.7.1/hadoop-yarn/hadoop-yarn-site/FairScheduler.html
			echo Configure Yarn at $1 step 2 $fairSchedulerFile
			if $isLocalhost
			then
				$SSH_CMD $username@$1 "echo  '<?xml version=\"1.0\"?>
<allocations>

<defaultQueueSchedulingPolicy>$shedulingPolicy</defaultQueueSchedulingPolicy>
<defaultMinSharePreemptionTimeout>1</defaultMinSharePreemptionTimeout>
<defaultFairSharePreemptionTimeout>1</defaultFairSharePreemptionTimeout>
<defaultFairSharePreemptionThreshold>1.0</defaultFairSharePreemptionThreshold>

<queue name=\"bursty0\">	
	<minReq>16384 mb, 16 vcores</minReq>
	<!-- <minReq>8192 mb, 8 vcores</minReq> -->
	<speedDuration>20000</speedDuration>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<period>100000</period>
	<startTime>-1</startTime>
	<weight>$weight</weight>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch0\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch1\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch2\">
	<weight>1</weight>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
</allocations>' > $fairSchedulerFile"
			else
			$SSH_CMD $username@$1 "echo  '<?xml version=\"1.0\"?>
<allocations>

<defaultQueueSchedulingPolicy>$shedulingPolicy</defaultQueueSchedulingPolicy>
<defaultMinSharePreemptionTimeout>1</defaultMinSharePreemptionTimeout>
<defaultFairSharePreemptionTimeout>1</defaultFairSharePreemptionTimeout>
<defaultFairSharePreemptionThreshold>1.0</defaultFairSharePreemptionThreshold>

<queue name=\"bursty0\">	
	<minReq>1310720 mb, 1280 vcores</minReq> 
	<!-- <minReq>16384 mb, 16 vcores</minReq> -->
	<speedDuration>20000</speedDuration>
	<period>200000</period>
	<startTime>-1</startTime>
	<weight>$weight</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch0\">
	<weight>1</weight>	
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch1\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch2\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch3\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch4\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch5\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch6\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"batch7\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>

</allocations>' > $fairSchedulerFile"
			fi

			echo Configure Yarn at $1 step 3 $capacitySchedulerFile
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\"?>
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
			echo Configure Yarn at $1 step 4 - mapred-site.xml
			# etc/hadoop/mapred-site.xml
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>

  <property>
    <name>mapreduce.framework.name</name>
    <!-- <value>$yarnFramework</value> -->
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

  <property>
    <name>tez.simulation.enabled</name>
    <value>$enableSim</value>
  </property>

</configuration>' > $hadoopFolder/$configFolder/mapred-site.xml"
			
			
			# monitoring script in etc/hadoop/yarn-site.xml
			echo Configure Yarn at $1 step 5 - $hadoopFolder/$configFolder/slaves
			# slaves etc/hadoop/slaves
			$SSH_CMD $username@$1 "sudo rm -rf $hadoopFolder/$configFolder/slaves"
			#slaveStr=""
			tempCMD=""
			for svr in $slaveNodes; do	
				#slaveStr="$slaveStr $svr"
				tempCMD="$tempCMD echo $svr >> $hadoopFolder/$configFolder/slaves; "		
				#$SSH_CMD $username@$1 "echo $svr >> $hadoopFolder/$configFolder/slaves"
			done
			$SSH_CMD $username@$1 "$tempCMD"
			#$SSH_CMD $username@$1 "echo $slaveStr > $hadoopFolder/$configFolder/slaves "
			#$SSH_CMD $username@$1 "sudo chown -R $username:$groupname $hadoopFolder"

}

		installHadoopPath(){
			if $isInitPath
			then	
				$SSH_CMD $username@$1 "echo export JAVA_HOME=$java_home >> .bashrc"				
				# Administrators can configure individual daemons using the configuration options shown below in the table:	
				#$SSH_CMD $username@$1 'echo export HADOOP_NAMENODE_OPTS="-XX:+UseParallelGC" > temp.txt'
				#$SSH_CMD $username@$1 "cat /$hadoopFolder/$configFolder/hadoop-env.sh temp.txt > temp2.txt; mv temp2.txt /$hadoopFolder/$configFolder/hadoop-env.sh"
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
				# $SSH_CMD $username@$1 "sed -i -e 's/#export HADOOP_HEAPSIZE=/export HADOOP_HEAPSIZE=4096/g' $hadoopFolder/$configFolder/hadoop-env.sh"
				# YARN_HEAPSIZE
				# $SSH_CMD $username@$server "sed -i -e 's/# YARN_HEAPSIZE=1000/# YARN_HEAPSIZE=4096/g' $hadoopFolder/$configFolder/yarn-env.sh"
			
				# configure HADOOP_PREFIX 
				$SSH_CMD $username@$1 "echo export HADOOP_PREFIX=~/$hadoopFolder >> .bashrc;
				echo export HADOOP_YARN_HOME=~/$hadoopFolder >> .bashrc;
				echo export HADOOP_HOME=~/$hadoopFolder >> .bashrc;				
				echo export HADOOP_CONF_DIR=~/$hadoopFolder/$configFolder >> .bashrc;
				echo export YARN_CONF_DIR=~/$hadoopFolder/$configFolder >> .bashrc; 
				source .bashrc"
				
			fi
}
			
		
		if $isUploadYarn 
		then
			# upload to the $masterNode
			$SSH_CMD $username@$masterNode "sudo rm -rf $hadoopTgz"
			sleep 3
			echo "scp $customizedHadoopPath $username@$masterNode:~/"
			scp $customizedHadoopPath $username@$masterNode:~/ 
			if $isLocalhost
			then
				echo "uploaded Yarn ..."
			else
				# share upload file among the workers.
				echo "multithread sharing...."
				uploadCMD=""
				counter=0
				for slave in $slaveNodes; do
					counter=$((counter+1))
					$SSH_CMD $username@$slave "sudo rm -rf $hadoopTgz"
					#uploadCMD="$uploadCMD scp $hadoopTgz $slave:~/ & "
					uploadCMD="$uploadCMD scp $hadoopTgz $slave:~/ ; "
				done
				#uploadCMD="$uploadCMD wait"
				echo $uploadCMD
				$SSH_CMD $username@$masterNode "$uploadCMD"
			fi
		fi
		counter=0
		for server in $serverList; do
			counter=$((counter+1))
			installHadoopFunc $server &
			installHadoopPath $server &
			if [[ "$counter" -gt $PARALLEL ]]; then
		       		counter=0;
				wait
		       	fi
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
		echo "install Spark at $1 - step 1"
		if $isDownload
		then
			ssh $1 "sudo rm -rf $sparkTgz; wget $sparkDownloadLink >> log.txt"
		fi
		echo "install Spark at $1 - step 2"
		if $isExtract
		then			
			ssh $1 "rm -rf $sparkFolder; tar -xvzf $sparkTgz >> log.txt; mv $sparkTgzFolder $sparkFolder"
		fi
		echo "install Spark at $1 - step 3"
		ssh $1 "echo 'export SPARK_DIST_CLASSPATH=~/$hadoopFolder/bin/hadoop
#export SPARK_JAVA_OPTS=-Dspark.driver.port=53411
export HADOOP_CONF_DIR=$hadoopFolder/$configFolder
export SPARK_MASTER_IP=$masterNode' > $sparkFolder/conf/spark-env.sh"
		echo "install Spark at $1 - step 4"
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
		echo "install Spark at $1 - step 5"
		#Create /opt/spark-ver/conf/slaves add all the hostnames of spark slave nodes to it.
		$SSH_CMD $1 "sudo rm -rf $sparkFolder/conf/slaves"
		for slave in $slaveNodes; do
			ssh $1 "echo $slave >> $sparkFolder/conf/slaves"
		done

		#ssh $1 "cp ~/spark/lib/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/ > .null.txt" 
		$SSH_CMD $1 "cp ~/spark/yarn/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/" # for 2.0.0 version
	}
	counter=0
	for server in $serverList; do
		counter=$((counter+1))
		installSparkFunc $server &	
		if [[ "$counter" -gt $PARALLEL ]]; then
	       		counter=0;
			wait
	       	fi
	done
	wait
#lse
#	for server in $serverList; do
#		#ssh $server "cp ~/spark/lib/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/ > .null.txt" 
#		$SSH_CMD $server "cp ~/spark/yarn/$sparkVer-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/" # for 2.0.0 version
#	done	
fi


########################## restart all #########################

if $restartHadoop
then
	# shutdown all before starting.
	echo "============================stopping Hadoop (HDFS) and Yarn ========================="
	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/stop-dfs.sh; $hadoopFolder/sbin/stop-yarn.sh"
	echo '============================ starting Hadoop==================================='

	if $isFormatHDFS
	then
		$SSH_CMD $username@$masterNode "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
		$SSH_CMD $username@$masterNode "yes Y | $hadoopFolder/bin/hdfs namenode -format HDFS4Flink"
	fi
	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/start-dfs.sh"
	echo '============================ starting Yarn==================================='
	# operating YARN
	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/start-yarn.sh"
	# operating MapReduce
	#$SSH_CMD $username@$masterNode '$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver'	
fi

if $isInstallSpark 
then 
	echo "#################################### start Spark #####################################"
	$SSH_CMD $masterNode "~/spark/sbin/stop-all.sh; ~/spark/sbin/start-all.sh;"
fi

########################################################## install TEZ##########################################


if $isInstallTez
then

	if $isUploadTez
	then
		# upload to the $masterNode
		$SSH_CMD $username@$masterNode "rm -rf $TEZ_JARS; mkdir $TEZ_JARS"
		echo "scp ~/projects/ccra/tez/tez-dist/target/$tezMinTaz $username@$masterNode:~/"
		scp ~/projects/ccra/tez/tez-dist/target/$tezMinTaz  $username@$masterNode:~/
		#if $isLocalhost
		#then
		#	echo "uploaded Tez ..."
		#else
		#	# share upload file among the workers.
		#	echo "multithread sharing...."
		#	uploadCMD=""
		#	counter=0
		#	for slave in $slaveNodes; do
		#		counter=$((counter+1))
		#		$SSH_CMD $username@$slave "rm -rf $TEZ_JARS; mkdir $TEZ_JARS"
		#		uploadCMD="$uploadCMD scp $tezMinTaz $slave:~/ ; "
		#	done
		#	uploadCMD="$uploadCMD"
		#	echo $uploadCMD
		#	$SSH_CMD $username@$masterNode "$uploadCMD"
		#fi
	fi

	installTezFunc () {
		#tez-site.xml configuration. (done)

		echo Configure Tez at $1 step 1 tez-site.xml
		$SSH_CMD $username@$1 "mkdir $TEZ_CONF_DIR"
		$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\"?>
		<configuration>
			<property>
			     <name>tez.am.container.reuse.enabled</name>
			     <value>false</value>
			</property>
			<property>
			     <name>tez.dag.profile.enable</name>
			     <value>true</value>
			</property>
			<property>
			     <name>tez.workload.trace</name>
			     <value>$workloadFile</value>
			</property>
			<property>
			     <name>tez.dag.profile.path</name>
			     <value>$profilePath</value>
			</property>
			<property>
			     <name>tez.simulation.log.enable</name>
			     <value>true</value>
			</property>
			<property>
			     <name>tez.simulation.log.path</name>
			     <value>$simLogPath</value>
			</property>
			<property>
			     <name>tez.queue.name</name>
			     <value>batch0</value>
			</property>
		  	<property>
			     <name>tez.lib.uris</name>
			     <value>hdfs://$masterNode:9000//apps/tez/tez-0.8.4.tar.gz</value>
			</property>
			<property>
			  <description>URL for where the Tez UI is hosted</description>
			  <name>tez.tez-ui.history-url.base</name>
			  <value>http://$hostname:9999/tez-ui/</value>
			</property>
			<property>
			     <name>tez.simulation.enabled</name>
			     <value>$enableSim</value>
			</property>
			<property>
			     <name>tez.node.capacity.vcores</name>
			     <value>$yarnVcores</value>
			</property>
			<property>
			     <name>tez.node.capacity.mem</name>
			     <value>$yarnNodeMem</value>
			</property>
			<property>
			     <name>tez.resource.scaledown</name>
			     <value>$scaleDown</value>
			</property>
			<property>
			     <name>tez.resource.singlenode</name>
			     <value>$isLocalhost</value>
			</property>			
			<property>
			     <name>tez.am.preemption.percentage</name>
			     <value>0</value>
			</property>
			<property>
			     <name>tez.am.preemption.max.wait-time-ms</name>
			     <value>100</value>
			</property>
			<property>
			     <name>tez.am.preemption.heartbeats-between-preemptions</name>
			     <value>1</value>
			</property>
		</configuration>' > $hadoopFolder/$tezConfigFolder/tez-site.xml"
		$SSH_CMD $username@$1 "mkdir $TEZ_JARS; tar -xvzf $tezMinTaz -C $TEZ_JARS"
	}

	$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -mkdir /apps"
	$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -mkdir /apps/tez"
	scp ~/projects/ccra/tez/tez-dist/target/tez-0.8.4.tar.gz $username@$masterNode:~/
	$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -rmr /apps/tez/tez-0.8.4.tar.gz;
	hadoop/bin/hadoop dfs -copyFromLocal tez-0.8.4.tar.gz /apps/tez/"
	scp $workloadSrcFile  $username@$masterNode:$workloadFile
	scp $genJavaFile $username@$masterNode:$genJavaFileDst
	echo "cd hadoop/conf; javac $genJavaFileDst; java $genJavaFileDst $workloadFile"
	$SSH_CMD $username@$masterNode "cd hadoop/conf; javac $genJavaFileDst; java GenerateProfile $workloadFile"
	installTezFunc $masterNode
	
	#counter=0
	#for server in $serverList; do
	#	counter=$((counter+1))
	#	installTezFunc $server &	
	#	if [[ "$counter" -gt $PARALLEL ]]; then
	#       		counter=0;
	#		wait
	#       	fi
	#done
	#wait

# test: hadoop/bin/hadoop jar hadoop/tez_jars/tez-tests-0.8.4.jar testorderedwordcount -DUSE_TEZ_SESSION=true input output
# test: hadoop/bin/hadoop jar hadoop/tez_jars/tez-examples-0.8.4.jar joindatagen -DUSE_TEZ_SESSION=true datagen1.txt 1024 datagen2.txt 1024 result_path 10 dagId
# -tez.queue.name=my_queue_name
fi



############################################### TEST CASES ###########################################
# upload test cases

echo ""
echo "[INFO] $hostname "
echo "[INFO] Finished at: $(date) "

