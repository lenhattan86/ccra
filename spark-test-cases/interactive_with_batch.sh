# Start timming
isLocalhost=true
yarnAppLogs="/dev/shm/yarn-logs"
username="tanle"

if $isLocalhost
then
	hostname="localhost"
	master="localhost"
	serverList="localhost"
else
	hostname="ctl.yarn-perf.yarnrm-pg0.utah.cloudlab.us"
	# private server listl
	master="ctl"
	serverList="$master cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
fi

if $isLocalhost
then
	cmdSpark="/home/tanle/spark/bin/spark-submit"
	jarFile="/home/tanle/spark/examples/jars/spark-examples*.jar"
else
	#jarFile="./spark/lib/spark-examples*.jar" 
	jarFile="../spark/examples/jars/spark-examples*.jar" # for spark 2.0
	#jarFile="./spark-examples*.jar" # for customized jars
	cmdSpark="../spark/bin/spark-submit"
fi

className="org.apache.spark.examples.SparkPi"
streamingClass="org.apache.spark.examples.streaming.HdfsWordCount"

#executorMem="1536M" # + 384
executorMem="768M" # + 384
executorCore="1"

mode="cluster"
#mode="client"

timeToStartBurstyApps=0

if [ -z "$1" ]
then
	numOfapps=1
else
	numOfapps=$1
fi

if [ -z "$2" ]
then
#	numOfIteration=100000
	numOfIteration=2000
else
	numOfIteration=$2
fi

if [ -z "$3" ]
then
	#sleepInterval=240  # at least 240
	sleepInterval=240  # for a single bursty app
else
	sleepInterval=$2
fi

if [ -z "$4" ]
then
	numOfBatchQueues=2
else
	numOfBatchQueues=$4
fi

if [ -z "$5" ]
then
	numOfBatchJobs=1
else
	numOfBatchJobs=$4
fi

if [ -z "$6" ]
then
	#batchIteration=$(($numOfIteration * 10 * $numOfapps))
#	batchIteration=100000
	batchIteration=1000    
else
	batchIteration=$5
fi

batchInterval=0

folder="log$numOfBatchQueues"
rm -rf $folder
mkdir $folder

isCopy=false

for server in $serverList; do		
	ssh $server "sudo rm -rf $yarnAppLogs/*" &
done

echo "start bursty and backlogging apps"

backlogBatchJobs () {	
	for i in `seq 1 $numOfBatchJobs`;
	do
		for qId in `seq 1 $numOfBatchQueues`;
		do
			echo "run batch_$qId_$i" 		
			FULL_COMMAND1="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue batch$qId $jarFile $batchIteration"
			(TIMEFORMAT='%R'; time $FULL_COMMAND1 2>$folder/batch_$qId_$i) 2> $folder/batch_$qId_$i.time &	
			batchids="$batchids $!"
		done		
	done
	wait $batchids
}

runburstyJobs () {	
	pids=""
	for i in `seq 1 $numOfapps`;
	do
		echo "run busrty $i"
		FULL_COMMAND2="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue bursty0 $jarFile $numOfIteration"
		(TIMEFORMAT='%R'; time $FULL_COMMAND2 2>$folder/busrty$i) 2> $folder/busrty$i.time &		
		pids="$pids $!"
		if test $i -lt $numOfapps
		then
			echo "sleep $sleepInterval"
			sleep $sleepInterval
		fi
	done
	wait $pids
}

python get_yarn_queue_info.py --master $hostname --interval 1 --file $folder/yarnUsedResources.csv & pythonScript=$!
backlogBatchJobs & batches=$!
echo "sleep $timeToStartBurstyApps"
sleep $timeToStartBurstyApps 
runburstyJobs & bursties=$!
#wait $bursties
wait $batches
kill $busties
kill $batches 
kill $pythonScript



#cat $folder/batch*.time > $folder/batches.txt
cat $folder/busrty*.time > $folder/busties.txt
rm $folder/*.time
