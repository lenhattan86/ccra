# Start timming

yarnAppLogs="/dev/shm/yarn-logs"
username="tanle"

#hostname="nm.yarnalytics.yarnrm-pg0.wisc.cloudlab.us"
hostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"
#hostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"

# private server listl
master="nm"
serverList="$master ctl cp-1 cp-2 cp-3"
#serverList="$master ctl cp-1"

#jarFile="./spark/lib/spark-examples*.jar" 
jarFile="../spark/examples/jars/spark-examples*.jar" # for spark 2.0
#jarFile="./spark-examples*.jar" # for customized jars

cmdSpark="../spark/bin/spark-submit"

className="org.apache.spark.examples.SparkPi"
streamingClass="org.apache.spark.examples.streaming.HdfsWordCount"

executorMem="1536M" # + 384
#executorMem="768M" # + 384
executorCore="1"

mode="cluster"
#mode="client"

timeToAcceptApp=0

if [ -z "$1" ]
then
	numOfapps=2
else
	numOfapps=$1
fi

if [ -z "$2" ]
then
#	numOfIteration=100000
	numOfIteration=500  	  
else
	numOfIteration=$2
fi

if [ -z "$3" ]
then
	#sleepInterval=240  # at least 240
	sleepInterval=240  # for a single interactive app
else
	sleepInterval=$2
fi

if [ -z "$4" ]
then
	numOfBatchJobs=5 
else
	numOfBatchJobs=$4
fi

if [ -z "$5" ]
then
	#batchIteration=$(($numOfIteration * 10 * $numOfapps))
#	batchIteration=100000
	batchIteration=100    
else
	batchIteration=$5
fi

folder="log$numOfapps"
rm -rf $folder
mkdir $folder

isCopy=false

for server in $serverList; do		
	ssh $server "sudo rm -rf $yarnAppLogs/*" &
done

echo "start interactive and backlogging apps"

backlogBatchJobs () {	
#	pids1=""	
	for i in `seq 1 $numOfBatchJobs`;
	do
		echo "run batch_1 $i" 		
		FULL_COMMAND1="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue batch0 $jarFile $batchIteration"
		(TIMEFORMAT='%R'; time $FULL_COMMAND1 2>$folder/batch1_$i) 2> $folder/batch_1$i.time & pid1=$!
		sleep 20; 
		if [ -v "$pid2" ]
		then
			echo "waiting for batch_2 $i"
			wait $pid2
		fi
		echo "run batch_2 $i"
		(TIMEFORMAT='%R'; time $FULL_COMMAND1 2>$folder/batch2_$i) 2> $folder/batch_2$i.time & pid2=$!
		echo "waiting for batch_1 $i"
		wait $pid1		
	done
	wait $pid2
}

runInteractiveJobs () {	
	pids=""
	for i in `seq 1 $numOfapps`;
	do
		echo "run interactive $i"
		FULL_COMMAND2="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue interactive0 $jarFile $numOfIteration"
		(TIMEFORMAT='%R'; time $FULL_COMMAND2 2>$folder/interactive$i) 2> $folder/interactive0$i.time &		
		pids="$pids $!"
		echo "sleep $sleepInterval"
		sleep $sleepInterval
		#FULL_COMMAND4="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue interactive1 $jarFile $numOfIteration"
		#(TIMEFORMAT='%R'; time $FULL_COMMAND4 2>$folder/interactive$i) 2> $folder/interactive1$i.time &		
		#	pids="$pids $!"
	done
	wait $pids
}

python get_yarn_queue_info.py --master $hostname --interval 1 --file $folder/yarnUsedResources.csv & pythonScript=$!
# tee -a "$folder/yarnUsedResources.csv" 
backlogBatchJobs & batches=$!
echo "sleep $timeToAcceptApp"
sleep $timeToAcceptApp 
runInteractiveJobs & interactives=$!
#wait $interactives
wait $batches
kill $pythonScript
kill $batches 
kill $interactives

#cat $folder/batch*.time > $folder/batches.txt
cat $folder/interactive*.time > $folder/interactives.txt
rm $folder/*.time

