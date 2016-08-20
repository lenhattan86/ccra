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
#jarFile="./spark/examples/jars/spark-examples*.jar" # for spark 2.0
jarFile="./spark-examples*.jar" # for customized jars


cmdSpark="./spark/bin/spark-submit"
#cmdSpark="/home/tan/projects/spark-1.6.1-bin-hadoop2.6/bin/spark-submit"


className="org.apache.spark.examples.SparkPi"
#streamingClass="org.apache.spark.examples.streaming.HdfsWordCount"
streamingClass="org.apache.spark.examples.streaming.CpuBound"

executorMem="1536M" # + 384
executorCore="1"

mode="cluster"

if [ -z "$1" ]
then
	numOfOverlaps=7
else
	numOfOverlaps=$1
fi

if [ -z "$2" ]
then
	numOfIteration=250000  
else
	numOfIteration=$2
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
#hdfs/dump_text_file.sh
# keep putting it to the hdfs
#python hdfs/hdfs_populator.py 1 59 & pidPuttingFile=$!
# Run a streaming app

#sleep 30

#./spark/bin/spark-submit --master yarn --class org.apache.spark.examples.CpuBound --deploy-mode cluster --driver-memory 1024M --executor-memory 1024M --executor-cores 1 --queue streaming ./spark-examples*.jar 1000
#./spark/bin/spark-shell --master yarn --driver-memory 1536M --executor-memory 1536M --executor-cores 1 --queue shell
#date --rfc-3339=seconds >> streaming.csv
#$cmdSpark --master yarn --class $streamingClass --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores 1 --queue streaming $jarFile /tmp/spark1 & pidStreamingJob=$!

#sleep 300

runAppOnTheSameQueue () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the spark app
	#./spark/bin/spark-submit --master yarn --class org.apache.spark.examples.SparkPi --deploy-mode cluster --driver-memory 2048M --executor-memory 2048M --executor-cores 1 --queue q2 ./spark-examples*.jar 1000
	$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue batchjob $jarFile $numOfIteration $timestampFile$2_$1.csv
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

runAppOnMultiQueues () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the spark app
	$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue q$1 $jarFile $numOfIteration $timestampFile$2_$1.csv
	#$cmdSpark --master yarn --class $streamingClass --deploy-mode $mode --driver-memory $executorMem --executor-memory $executorMem --executor-cores $executorCore --queue q$1 $jarFile $numOfIteration $timestampFile$2_$1.csv
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

# Run the batch jobs
pids=""
for numLaps in `seq 1 $numOfOverlaps`;
do
	runAppOnMultiQueues $i $numLaps &
	#sleep 300		
done

#kill $pidPuttingFile
#kill $pidStreamingJob
date --rfc-3339=seconds >> streaming.csv
