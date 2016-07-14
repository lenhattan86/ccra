# Start timming
yarnAppLogs="/media/ephemeral0/yarn-logs"
yarnLocalOLogs="/media/ephemeral0/yarn-local"

# private server listl
master="ip-172-31-1-175.us-west-2.compute.internal"
severList="$master 
ip-172-31-1-177.us-west-2.compute.internal
ip-172-31-1-171.us-west-2.compute.internal
ip-172-31-1-170.us-west-2.compute.internal
ip-172-31-1-174.us-west-2.compute.internal
ip-172-31-1-173.us-west-2.compute.internal
ip-172-31-1-172.us-west-2.compute.internal
ip-172-31-1-176.us-west-2.compute.internal
ip-172-31-1-178.us-west-2.compute.internal
ip-172-31-1-179.us-west-2.compute.internal
ip-172-31-1-180.us-west-2.compute.internal"

jarFile="./spark/lib/spark-examples*.jar"
#jarFile="spark-examples-1.6.1-hadoop2.4.0.jar"

cmdSpark="./spark/bin/spark-submit"
#cmdSpark="/home/tan/projects/spark-1.6.1-bin-hadoop2.6/bin/spark-submit"


className="org.apache.spark.examples.SparkPi"

numOfOverlaps=4
numOfExp=3
folder="cpubound-log"
rm -rf $folder
mkdir $folder

timestampFile="$folder/cpubound"


isCopy=false

for server in $serverList; do		
	ssh $server "sudo rm -rf $yarnAppLogs/*" &
	ssh $server "sudo rm -rf $yarnLocalLogs/*" &
done
wait
~/hadoop/bin/hadoop fs -rm -r  hdfs:///tmp/logs/ec2-user/logs/*
~/hadoop/bin/hadoop fs -rm -r  hdfs:///user/ec2-user/.sparkStaging/*

echo "start overlap experiments"

# Run a streaming app
$cmdSpark --master yarn --class $className --deploy-mode cluster --driver-memory 512M --executor-memory 512M --executor-cores 1 --queue streaming $jarFile 5000000

sleep 15

runAppOnTheSameQueue () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the spark app
	$cmdSpark --master yarn --class $className --deploy-mode cluster --driver-memory 512M --executor-memory 512M --executor-cores 1 --queue batchjob $jarFile 10000 $timestampFile$2_$1.csv > tmp.txt
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

runAppOnMultiQueues () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the spark app
	$cmdSpark --master yarn --class $className --deploy-mode cluster --driver-memory 512M --executor-memory 512M --executor-cores 1 --queue q$1 $jarFile 10000 $timestampFile$2_$1.csv > tmp.txt
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

# Run the batch jobs
for numLaps in `seq 1 $numOfOverlaps`;
do
	for count in `seq 1 $numOfExp`;
	do
		
		for i in `seq 1 $numLaps`;
		do		/
			# run the Flink app
			# runAppOnMultiQueues $i $numLaps &
			runAppOnTheSameQueue	$i $numLaps &
		done	
		wait
		sleep 15		
	done
	for server in $serverList; do		
		ssh $server "sudo rm -rf $yarnAppLogs/*" &
		ssh $server "sudo rm -rf $yarnLocalLogs/*" &
	done
	wait
	~/hadoop/bin/hadoop fs -rm -r  hdfs:///tmp/logs/ec2-user/logs/*
	~/hadoop/bin/hadoop fs -rm -r  hdfs:///user/ec2-user/.sparkStaging/*
	
done
