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

executorMem="1024M" # + 384
executorCore="1"

mode="cluster"

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

date --rfc-3339=seconds >> $folder/streaming.csv
$cmdSpark --master yarn --class $streamingClass --deploy-mode $mode --driver-memory 2048M --executor-memory 2048M --executor-cores 1 --queue streaming $jarFile /tmp/spark1 & pidStreamingJob=$!
sleep 60

numOfApp=7
runApp() {
	case "$1" in
	1) 	# 1/2
		mem="1024M"
		cores=1
		task=150000 ;;
	2) echo # 1/5
		mem="4096M"
		cores=1
		task=150000 ;;
	3) # 6/2
		mem="1024M"
		cores=6
		task=150000 ;;
	4) # 12/2
		mem="1024M"
		cores=12
		task=150000 ;;
	5) # 3/2
		mem="1024M"
		cores=3
		task=150000 ;;
	6) # 2/3
		mem="2048M"
		cores=2
		task=150000 ;;
	7) # 4/3
		mem="2048M"
		cores=4
		task=150000 ;;
	esac	

	date --rfc-3339=seconds >> $timestampFile$1.csv
	# run the spark app
	$cmdSpark --master yarn --class $className --deploy-mode $mode --driver-memory $mem --executor-memory $mem --executor-cores $cores --queue q$1 $jarFile $task
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$1.csv
}

deleteLogs(){
	for server in $serverList; do	
		ssh $server "sudo rm -rf $yarnAppLogs/*" &
		pids="$pids $!"
	done
	wait $pids
}

# Run the 2 batch jobs

pids=""
for i in `seq 1 $numOfApp`;
do	
	for j in `seq $(( i + 1 )) $numOfApp`;
	do 
		for k in `seq $(( j + 1 )) $numOfApp`;
		do	
			echo $i $j $k
			# run the Flink app		
			runApp $i &
			pids="$pids $!"
			sleep 30
			runApp $j &
			pids="$pids $!"
			sleep 30
			runApp $k &
			pids="$pids $!"
			wait $pids
		done
	done	
	#sleep 60
done	
# single batch job	
	
kill $pidPuttingFile
kill $pidStreamingJob
date --rfc-3339=seconds >> $folder/streaming.csv
