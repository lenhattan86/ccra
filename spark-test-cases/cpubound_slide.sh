# Start timming
#yarnAppLogs="/users/tanle/yarn-logs"
yarnAppLogs="/dev/shm/yarn-logs"
username="tanle"

# private server listl
master="nm"
serverList="$master 
cp-1
cp-2
cp-3
cp-4
cp-5
cp-6
cp-7
cp-8"

#jarFile="./spark/lib/spark-examples*.jar" 
jarFile="./spark/examples/jars/spark-examples*.jar" # for spark 2.0


cmdSpark="./spark/bin/spark-submit"
#cmdSpark="/home/tan/projects/spark-1.6.1-bin-hadoop2.6/bin/spark-submit"


className="org.apache.spark.examples.SparkPi"
streamingClass="org.apache.spark.examples.streaming.HdfsWordCount"

executorMem="2048M" # + 384
executorCore="1"

mode="cluster"

if [ -z "$1" ]
then
	numOfOverlaps=2
else
	numOfOverlaps=$1
fi

if [ -z "$2" ]
then
	numOfExp=1
else
	numOfExp=$2
fi

if [ -z "$3" ]
then
	numOfIteration=200000  
else
	numOfIteration=$3
fi



folder="cpubound-log"
rm -rf $folder
mkdir $folder

timestampFile="$folder/cpubound"


isCopy=false

for server in $serverList; do		
	ssh $server "sudo rm -rf $yarnAppLogs/*" &
done

~/hadoop/bin/hadoop fs -rm -r  hdfs:///tmp/logs/$username/logs/*
~/hadoop/bin/hadoop fs -rm -r  hdfs:///user/$username/.sparkStaging/*

echo "start overlap experiments"

# create big text
hdfs/dump_text_file.sh
# keep putting it to the hdfs
python hdfs/hdfs_populator.py 1 60 & pidPuttingFile=$!
# Run a streaming app

date --rfc-3339=seconds >> streaming.csv
$cmdSpark --master yarn --class $streamingClass --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores 1 --queue streaming $jarFile /tmp/spark1 & pidStreamingJob=$!

sleep 60

runAppOnTheSameQueue () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the spark app
	$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue batchjob $jarFile $numOfIteration $timestampFile$2_$1.csv
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

runAppOnMultiQueues () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the spark app
	$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue q$1 $jarFile $numOfIteration $timestampFile$2_$1.csv
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

# Run the batch jobs
for numLaps in `seq 1 $numOfOverlaps`;
do
	for count in `seq 1 $numOfExp`;
	do
		pids=""
		for i in `seq 1 $numLaps`;
		do		
			# run the Flink app
			sleep 1
			runAppOnMultiQueues $i $numLaps &
			#runAppOnTheSameQueue	$i $numLaps &
			pids="$pids $!"
		done	
		wait $pids
		sleep 60		
	done
	pids=""
	for server in $serverList; do	
		echo 'delete yarn logs'	
		ssh $server "sudo rm -rf $yarnAppLogs/*" &
		pids="$pids $!"
	done
	wait $pids
	~/hadoop/bin/hadoop fs -rm -r  hdfs:///tmp/logs/$username/logs/*
	~/hadoop/bin/hadoop fs -rm -r  hdfs:///user/$username/.sparkStaging/*
	sleep 120
done

kill $pidPuttingFile
kill $pidStreamingJob
date --rfc-3339=seconds >> streaming.csv
