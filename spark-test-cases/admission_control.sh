# Start timming

yarnAppLogs="/dev/shm/yarn-logs"
username="tanle"

#hostname="nm.yarnalytics.yarnrm-pg0.wisc.cloudlab.us"
hostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"

# private server listl
master="nm"
#serverList="$master ctl cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
serverList="$master ctl cp-1"

#jarFile="./spark/lib/spark-examples*.jar" 
jarFile="./spark/examples/jars/spark-examples*.jar" # for spark 2.0
#jarFile="./spark-examples*.jar" # for customized jars

cmdSpark="./spark/bin/spark-submit"

className="org.apache.spark.examples.SparkPi"
streamingClass="org.apache.spark.examples.streaming.HdfsWordCount"

executorMem="1536M" # + 384
#executorMem="768M" # + 384
executorCore="1"

mode="cluster"
#mode="client"

timeToAcceptApp=60

if [ -z "$1" ]
then
	numOfapps=3
else
	numOfapps=$1
fi

if [ -z "$2" ]
then
	numOfIteration=10000  
else
	numOfIteration=$2
fi

if [ -z "$3" ]
then
	#sleepInterval=240  # at least 240
	sleepInterval=15  # for a single interactive app
else
	sleepInterval=$2
fi

if [ -z "$4" ]
then
	numOfBatchJobs=2 
else
	numOfBatchJobs=$4
fi

if [ -z "$5" ]
then
	#batchIteration=$(($numOfIteration * 10 * $numOfapps))
	batchIteration=10000
#	batchIteration=10000    
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

echo "start admission control for N interactive and backlogging batch jobs"

backlogBatchJobs () {	
	for i in `seq 1 $numOfBatchJobs`;
	do
		echo "run batch_1 $i" 		
		FULL_COMMAND1="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue batch $jarFile $batchIteration"
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
		FULL_COMMAND2="$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue interactive$i $jarFile $numOfIteration"
		(TIMEFORMAT='%R'; time $FULL_COMMAND2 2>$folder/interactive$i) 2> $folder/interactive$i.time &		
		pids="$pids $!"		
	done
	wait $pids
}

python get_yarn_queue_info.py --master $hostname --interval 1 --file $folder/yarnUsedResources.csv & pythonScript=$!
backlogBatchJobs & batches=$!
echo "sleep $timeToAcceptApp"
sleep $timeToAcceptApp 
runInteractiveJobs & interactives=$!
wait $interactives
kill $pythonScript
kill $batches 

#cat $folder/batch*.time > $folder/batches.txt
cat $folder/interactive*.time > $folder/interactives.txt
rm $folder/*.time

