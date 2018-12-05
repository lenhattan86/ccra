#!/bin/bash
# usage:
# ./auto_setup_cluster.sh [hostname] [cloudlab site] [method] [parameters]
## constants

echo "waiting for compiling"

BPF="BPF"
BoPF="BoPF"
DRF="DRF"
N_BPF="N-BPF"
Strict="Strict"
DRFW="DRF-W"
Fair="Fair"

METHOD=$BoPF


if [ -z "$2" ]
then
	cloudlabSite='utah'
else
	cloudlabSite="$2"
fi

if [ -z "$1" ]
then
	cluster="bpf"	
	cp ~/.ssh/config.$cluster ~/.ssh/config; 
	hostname="ctl.$cluster.yarnrm-pg0.$cloudlabSite.cloudlab.us"
else
	cluster=$1
	hostname="ctl.$cluster.yarnrm-pg0.$cloudlabSite.cloudlab.us"; cp ~/.ssh/config.$cluster ~/.ssh/config;  
fi

if [ -z "$3" ]
then
	METHOD=$BoPF
else
	METHOD="$3"
fi

if [ -z "$4" ]
then
	parameters="1_1_40_BB_mov"
else
	parameters=$4
fi

## author: Tan N. Le ~ CS department Stony Brook University

### DO this command first at master node #####

# $sudo apt-get install -y rrdtool  ganglia-webfrontend

######################### enviromental variables ##############

set|grep AUTOSSH
AUTOSSH_GATETIME=0
AUTOSSH_PORT=20000

######################### System Variables #####################

isUploadKey=false
IS_INIT=false
isCloudLab=true
isAmazonEC=false
isLocalhost=false
isTestNetwork=false
isOfficial=false
TEST=true
SSH_CMD="autossh"
#SSH_CMD="ssh -v "
yarnFramework="yarn"
enableSim="true"
enablePreemption="false"
enableContainerLog="false"

if $isOfficial
then
	scaleDown=1.0 # DEFAULT 1.0
else
	scaleDown=4.0 # use 4.0 to increase the number of tasks -> 4 times.
fi

if $isLocalhost
then
	isUploadKey=false
	isCloudLab=false
	isAmazonEC=false
	IS_INIT=false
	scaleDown=1.0
	METHOD=$BoPF
fi
username="tanle"
groupname="yarnrm-PG0"

workloadSrcFile="/home/tanle/projects/BPFSim/input/jobs_input_$parameters.txt"
#workloadSrcFile="/home/tanle/projects/BPFSim/input/jobs_input_1_1_40_BB_mov.txt"
genJavaFile="/home/tanle/projects/BPFImpl/SWIM/GenerateProfile.java"

javaVer="8"
java_home="/usr/lib/jvm/java-$javaVer-oracle"

## Proposed Parameters

#PERIOD=300000 #200000
#STAGE01=27000
#PERIOD=600000 
#STAGE01=300000

# motivation
PERIOD=600000 
STAGE01=300000

######################### Hadoop  #####################
hadoopFolder="hadoop"
configFolder="etc/hadoop"
tezConfigFolder="etc/tez"

if $isLocalhost
then
	workloadSrcFile="/home/tanle/projects/BPFSim/input/jobs_input_3_1_1_BB.txt"
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

yarnVcores=16

vmemRatio=4
#yarnNodeMem=131072 # 128 GB
#yarnNodeMem=65536 # 64 GB
yarnNodeMem=$(($yarnVcores*1024*3)) # 3 times of number of vcores
#yarnNodeMem=32768 # 32 GB

if $isLocalhost
then
	yarnVcores=16
	yarnNodeMem=$(($yarnVcores*1024)) 
fi

yarnMaxMem=$yarnNodeMem # for each container

	
echo "METHOD: $METHOD"

if [ "$METHOD" == "$BPF" ];
then
    shedulingPolicy="bpf"; weight=1
elif [ "$METHOD" == "$BoPF" ];
then
	shedulingPolicy="BoPF"; weight=1
elif [ "$METHOD" == "$N_BPF" ];
then
	shedulingPolicy="n-bpf"; weight=1
elif [ "$METHOD" == "$DRF" ];
then
	shedulingPolicy="drf"; weight=1
elif [ "$METHOD" == "$Strict" ];
then
	shedulingPolicy="drf"; weight=999999
elif [ "$METHOD" == "$Fair" ];
then
	shedulingPolicy="fair"; weight=1
elif [ "$METHOD" == "$DRFW" ];
then
	shedulingPolicy="drf"; weight=4
else
	echo "[ERROR] This METHOD $METHOD does not exist."; exit;
	shedulingPolicy="drf";
fi

echo $schedulingPolicy

hdfsDir="/dev/hdfs"
if $isLocalhost; then
	hdfsDir="/ssd/hdfs"
fi

# hdfsDir="/users/tanle/hdfs"
#hdfsDir="$temp/hdfs"
#hdfsDir="/proj/yarnrm-PG0/hdfs"
# spark_tmp="/proj/yarnrm-PG0/spark"
spark_tmp="/tmp/spark"

#yarnAppLogs="/dev/yarn-logs"
yarnAppLogs="/dev/shm/yarn-logs" # only used in hadoop 2.7
#yarnAppLogs="/users/$username/yarn-logs" # for hadoop 2.6

cgroupYarn="~/$hadoopFolder/cgroup"
numOfReplication=1


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
sparkTgz="$sparkVer-bin-hadoop2.7.tgz"
sparkTgzFolder="$sparkVer-bin-hadoop2.7"

sparkDownloadLink="https://archive.apache.org/dist/spark/$sparkVer/$sparkTgz"

##########

PARALLEL=41
passwordLessParralel=2

if $isLocalhost
then
	hostname="localhost"; 
fi
yarnPort=9099
echo "[INFO] =====set up $hostname:$yarnPort ====="

REBOOT=false	

isUploadYarn=false
isDownload=false
if $isLocalhost
then
	isUploadYarn=true
	isDownload=false
fi


isInstallHadoop=true
isExtract=false
isFormatHDFS=false

isMapHostnames=false
if $isLocalhost
then
	isMapHostnames=false
fi

isInstallTez=false
isUploadTez=true

if $isUploadYarn
then
	isExtract=true
elif $isDownload
then
	isExtract=true	
fi

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
	METHOD=$DRF
	isInitPath=true
fi
isModifyHadoop=false
isShutDownHadoop=false
restartHadoop=true


isInstallFlink=false
isModifyFlink=false
startFlinkYarn=false
shudownFlink=false
startFlinkStandalone=false # not necessary

isInstallSpark=true
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
fi

if $isInstallSpark
then
	shuffleStr="mapreduce_shuffle,spark_shuffle"
else
	shuffleStr="mapreduce_shuffle"
fi


if $IS_INIT
then	
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

	isInstallSpark=true

	isInstallTez=false
	isUploadTez=true
	isTestNetwork=true
fi

if $isLocalhost
then
	echo "[INFO] Setup Yarn on localhost"
	masterNode=$hostname
	serverList=$hostname
	slaveNodes=$hostname
	numOfReplication=1
	numOfworkers=1
	isUploadKey=false
#	isUploadKey=true
#	isGenerateKey=true
	isInstallBasePackages=false
	isInstallGanglia=false
	isInstallFlink=false
	isAddToGroup=false
	isInitPath=false # use it if working on the new computer

	# isDownload=false
	# isUploadYarn=true
	# isExtract=true

	# isInstallTez=true
	# isUploadTez=true
elif $isCloudLab
then
	echo "[INFO]  at CLOUDLAB "
	masterNode="ctl"
	if $isOfficial
	then
		numOfworkers=40
		slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-14 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-28 cp-29 cp-30 cp-31 cp-32 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40"
		# slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-14 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20"
		serverList="$masterNode $slaveNodes"				
		numOfReplication=1
	else
		if $TEST
		then
			numOfworkers=4
			slaveNodes="cp-1 cp-2 cp-3 cp-4"
			serverList="$masterNode $slaveNodes"			
			numOfReplication=1

		else
			numOfworkers=8			
			masterNode="ctl"; slaveNodes="cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
			serverList="$masterNode $slaveNodes"
			numOfReplication=1
		fi
	fi
elif $isAmazonEC
then
	echo "[INFO] Amazon EC"
fi

hadoopVersion="2.7.2.1"
if $isDownload
then
	hadoopVersion="2.7.2"
fi

hadoopFullVer="hadoop-$hadoopVersion"
hadoopLink="https://archive.apache.org/dist/hadoop/core/hadoop-$hadoopVersion/hadoop-$hadoopVersion.tar.gz"
hadoopTgz="hadoop-$hadoopVersion.tar.gz"
customizedHadoopPath="/home/tanle/projects/BPFImpl/hadoop/hadoop-dist/target/$hadoopTgz"

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
	echo "[INFO] Waiting for 15 mins for the cluster to be ready."
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
			sudo rm -rf $HOME/.ssh/id_rsa*
			sudo rm -rf $HOME/.ssh/authorized_keys*
			yes Y | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa	
			cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
			sudo chmod 0600 $HOME/.ssh/id_rsa*
			sudo chmod 0600 ~/.ssh/authorized_keys
			echo 'StrictHostKeyChecking no' >> ~/.ssh/config
			if $isLocalhost
			then
				ssh-add
			fi
			break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
	    done 	
		
	fi
	uploadKeys () { 
		echo upload keys to $1
#		$SSH_CMD $username@$1 'sudo rm -rf $HOME/.ssh/id_rsa*'
		scp ~/.ssh/id_rsa* $username@$1:~/.ssh/
		$SSH_CMD $username@$1 "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys ;
		 chmod 0600 ~/.ssh/id_rsa*; 
		 chmod 0600 ~/.ssh/authorized_keys; 
		 rm -rf ~/.ssh/known_hosts; 	
		 echo 'StrictHostKeyChecking no' >> ~/.ssh/config"
		$SSH_CMD $username@$1 "sudo hostname $1" ;
	}
	rm -rf ~/.ssh/known_hosts

	echo "[INFO] uploading keys"
	for server in $serverList; do
		uploadKeys $server
	done	
	wait
fi

echo ####################### TEST CLUSTER NETWORK ##########################
if $isTestNetwork
then
	for server in $serverList; do
	$SSH_CMD $username@$server " echo Hello $server "
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
	
	counter=0;
	for server1 in $serverList; do
		for server2 in $serverList; do		
		  counter=$((counter+1))
			passwordlessSSH $server1 $server2 &
		  if [[ "$counter" -gt $passwordLessParralel ]]; then
	      counter=0;
			  wait
	    fi		
		done
	done
	wait
fi


if $isInstallBasePackages
then
	echo "################################# install JAVA ######################################"
	installPackages () {
		$SSH_CMD $username@$1 "sudo apt-get -y install $SSH_CMD
			sudo apt-get purge -y openjdk*
			sudo apt-get purge -y oracle-java*
			sudo apt-get install -y software-properties-common			
			sudo apt-get install -y python-software-properties debconf-utils
			sudo add-apt-repository -y ppa:webupd8team/java
			sudo apt-get update
			echo 'oracle-java$javaVer-installer shared/accepted-oracle-license-v1-1 select true' | sudo debconf-set-selections
			sudo apt-get install -y oracle-java$javaVer-installer
			sudo apt install oracle-java$javaVer-set-default"
		$SSH_CMD $username@$1 "sudo apt-get install -y cgroup-tools; sudo apt-get install -y scala; sudo apt-get install -y vim"	
		$SSH_CMD $username@$1 "sudo apt-get install maven -y"	
	}
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
	echo "[INFO] Configure Ganglia master node $masterNode"
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
			if $isFormatHDFS; then
				$SSH_CMD $username@$1 "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
			fi
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

			echo "[INFO] Configure Yarn at $1 step 0"

			# etc/hadoop/yarn-site.xml
			## Configurations for ResourceManager and NodeManager:

			$SSH_CMD $username@$1 "sudo rm -rf $yarnAppLogs; sudo mkdir $yarnAppLogs; sudo chmod 777 $yarnAppLogs"

			echo "[INFO] Configure Yarn at $1 step 1 yarn-site.xml"
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\"?>
<configuration>

  <property>
    <name>hadoop.http.staticuser.user</name>
    <value>yarn</value>
  </property>

  <property>
    <name>yarn.acl.enable</name>
    <value>false</value>
  </property>

  <property>
    <name>yarn.admin.acl</name>
    <value>$username</value>
  </property>		

  <property>
    <name>tez.simulation.enabled</name>
    <value>$enableSim</value>
  </property>

  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>$masterNode</value>
  </property>

  <property>
	<name>yarn.resourcemanager.webapp.address</name>
    <value>$masterNode:$yarnPort</value>
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
    <value>0.5</value>
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

  <property>
	<name>job.info.path</name>
	<value>$profilePath</value>
  </property>

  <property>
    <name>yarn.container.time.log.enable</name>
    <value>$enableContainerLog</value>
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
			echo "[INFO] Configure Yarn at $1 step 2 $fairSchedulerFile"
			if $isLocalhost
			then
				$SSH_CMD $username@$1 "echo  '<?xml version=\"1.0\"?>
<allocations>

<defaultQueueSchedulingPolicy>$shedulingPolicy</defaultQueueSchedulingPolicy>
<defaultMinSharePreemptionTimeout>1</defaultMinSharePreemptionTimeout>
<defaultFairSharePreemptionTimeout>1</defaultFairSharePreemptionTimeout>
<defaultFairSharePreemptionThreshold>1.0</defaultFairSharePreemptionThreshold>

<queue name=\"bursty0\">	
	<minReq>26624 mb, 13 vcores</minReq>
	<speedDuration>$STAGE01</speedDuration>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<period>600000</period>
	<startTime>-1</startTime>
	<weight>$weight</weight>
	<schedulingPolicy>$shedulingPolicy</schedulingPolicy>
</queue>
<queue name=\"batch0\">
	<weight>1</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>	
	<schedulingPolicy>$shedulingPolicy</schedulingPolicy>
</queue>

</allocations>' > $fairSchedulerFile"
			else

#strBQ=""
#for bId in seq(1,$numBatchQ); do
#	$SSH_CMD $username@$server " echo Hello $server " &
#done
			$SSH_CMD $username@$1 "echo  '<?xml version=\"1.0\"?>
<allocations>

<defaultQueueSchedulingPolicy>drf</defaultQueueSchedulingPolicy>
<defaultMinSharePreemptionTimeout>1</defaultMinSharePreemptionTimeout>
<defaultFairSharePreemptionTimeout>1</defaultFairSharePreemptionTimeout>
<defaultFairSharePreemptionThreshold>1.0</defaultFairSharePreemptionThreshold>

<queue name=\"dr_dot_who\">
	<aclSubmitApps>$username</aclSubmitApps>
	<weight>0</weight>
</queue>

<queue name=\"bursty0\">	
	<minReq>491520 mb, 160 vcores</minReq> 
	<speedDuration>$STAGE01</speedDuration>
	<period>600000</period>
	<startTime>-1</startTime>
	<weight>$weight</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>

<!--
<queue name=\"bursty1\">	
	<minReq>2621440 mb, 1280 vcores</minReq> 
	<speedDuration>$STAGE01</speedDuration>
	<period>110000</period>
	<startTime>-1</startTime>
	<weight>$weight</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue>
<queue name=\"bursty2\">	
	<minReq>2621440 mb, 1280 vcores</minReq> 
	<speedDuration>$STAGE01</speedDuration>
	<period>60000</period>
	<startTime>-1</startTime>
	<weight>$weight</weight>
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>fifo</schedulingPolicy>
</queue> 
-->

<queue name=\"batch0\">
	<weight>1</weight>	
	<allowPreemptionFrom>$enablePreemption</allowPreemptionFrom>
	<schedulingPolicy>$shedulingPolicy</schedulingPolicy>
</queue>

<!--
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
-->
</allocations>' > $fairSchedulerFile"
			fi

			echo "[INFO] Configure Yarn at $1 step 3 $capacitySchedulerFile"
			$SSH_CMD $username@$1 "echo '<?xml version=\"1.0\"?>
<configuration>
  <property>
    <name>yarn.scheduler.capacity.resource-calculator</name>
    <value>org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator</value>
    <description>Default allocator</description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.queues</name>
    <value>tanle</value>
    <description>The queues at the this level (root is the root queue).
    </description>
  </property>
  
  <property>
    <name>yarn.scheduler.capacity.root.tanle.capacity</name>
    <value>50</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.tanle.maximum-capacity</name>
    <value>100</value>
  </property>
  
</configuration>' > $capacitySchedulerFile"
			echo "[INFO] Configure Yarn at $1 step 4 - mapred-site.xml"
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
			echo "[INFO] Configure Yarn at $1 step 5 - $hadoopFolder/$configFolder/slaves"
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
				echo "[INFO] uploaded Yarn ..."
			else
				# share upload file among the workers.
				echo "[INFO] multithread sharing...."
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
		echo "[INFO] install Spark at $1 - step 1"				
		ssh $1 "sudo rm -rf $sparkTgz; wget $sparkDownloadLink >> log.txt"	

		echo "[INFO] install Spark at $1 - step 2"
		ssh $1 "rm -rf $sparkFolder; tar -xvzf $sparkTgz >> log.txt; mv $sparkTgzFolder $sparkFolder"

		echo "[INFO] install Spark at $1 - step 3"		
		$SSH_CMD $username@$1 "sudo rm -rf $spark_tmp; sudo mkdir $spark_tmp; sudo chmod 777 $spark_tmp"
		ssh $1 "echo 'export SPARK_DIST_CLASSPATH=~/$hadoopFolder/bin/hadoop
#export SPARK_JAVA_OPTS=-Dspark.driver.port=53411
export HADOOP_CONF_DIR=~/$hadoopFolder/$configFolder
export SPARK_MASTER_IP=$masterNode
export SPARK_LOCAL_DIRS=$spark_tmp' > $sparkFolder/conf/spark-env.sh"
		echo "install Spark at $1 - step 4"

		ssh $1 "echo '
# spark.yarn.driver.memoryOverhead=512
# spark.yarn.executor.memoryOverhead=1024
# spark.network.timeout=800

# spark.executor.memory 1024m

# spark.dynamicAllocation.enabled true
# spark.executor.instances 10000

# spark.dynamicAllocation.executorIdleTimeout 5
# spark.dynamicAllocation.schedulerBacklogTimeout 5
# spark.dynamicAllocation.sustainedSchedulerBacklogTimeout 5
# spark.dynamicAllocation.cachedExecutorIdleTimeout 900

# spark.shuffle.service.enabled true
# spark.shuffle.service.port 7338

# spark.scheduler.mode FAIR

# spark.task.maxFailures 999
# spark.yarn.max.executor.failures 999

# spark.streaming.dynamicAllocation.enabled true
# spark.streaming.dynamicAllocation.scalingUpRatio 0.0005
# spark.streaming.dynamicAllocation.scalingDownRatio 0.0000001
# spark.streaming.dynamicAllocation.minExecutors 1
# spark.streaming.dynamicAllocation.maxExecutors 500
' > $sparkFolder/conf/spark-defaults.conf"
		echo "[INFO] install Spark at $1 - step 5"
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
		# $SSH_CMD $username@$masterNode "sudo rm -rf $hdfsDir; sudo mkdir $hdfsDir; sudo chmod 777 $hdfsDir"
		$SSH_CMD $username@$masterNode "yes Y | $hadoopFolder/bin/hdfs namenode -format HDFS4Flink"
	fi
    sleep 30
	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/start-dfs.sh"
	echo '============================ starting Yarn==================================='
	# operating YARN
	$SSH_CMD $username@$masterNode "$hadoopFolder/sbin/start-yarn.sh"
	# operating MapReduce
	#$SSH_CMD $username@$masterNode '$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver'	
fi

# if $isInstallSpark 
# then 
# 	echo "#################################### start Spark #####################################"
# 	$SSH_CMD $masterNode "~/spark/sbin/stop-all.sh; ~/spark/sbin/start-all.sh;"
# fi

########################################################## install TEZ##########################################


if $isInstallTez
then
  echo "#####################Install TEZ##############################"
	if $isUploadTez
	then
		# upload to the $masterNode
		$SSH_CMD $username@$masterNode "rm -rf $TEZ_JARS; mkdir $TEZ_JARS"
		scp ~/projects/BPFImpl/tez/tez-dist/target/$tezMinTaz  $username@$masterNode:~/		
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
			     <value>false</value> <!-- tez_container_time.csv -->
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

			<property>
			     <name>tez.container.log.enable</name>
			     <value>$enableContainerLog</value>
			</property>
		</configuration>' > $hadoopFolder/$tezConfigFolder/tez-site.xml"
		$SSH_CMD $username@$1 "mkdir $TEZ_JARS; tar -xvzf $tezMinTaz -C $TEZ_JARS"
	}

	$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -mkdir /apps"
	$SSH_CMD $username@$masterNode "hadoop/bin/hadoop dfs -mkdir /apps/tez"
	scp ~/projects/BPFImpl/tez/tez-dist/target/tez-0.8.4.tar.gz $username@$masterNode:~/
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
echo "[INFO] $hostname:$yarnPort "
echo "[INFO] Finished at: $(date) "

## Dr.who attack
# sudo iptables -A INPUT -p tcp --dport 8088 -m state --state NEW,ESTABLISHED -j DROP
# sudo iptables -D INPUT -p tcp -m tcp --dport 8088 -m state --state NEW,ESTABLISHED -j DROP