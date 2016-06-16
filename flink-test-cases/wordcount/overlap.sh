# Start timming
#flink="../../build-target"
flink="$HOME/flink-1.0.3"
rm -rf overlap*.csv
numOfOverlaps=4
isCopy=false

yarnAppLogs="/dev/shm/yarn-logs"
serverList="nm cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"

for server in $serverList; do		
	ssh tanle@$server "sudo rm -rf $yarnAppLogs/*" &
done

if $isCopy
then
	echo "copy files"
	for i in `seq 1 $numOfOverlaps`;
	do		
		~/hadoop-2.7.0/bin/hadoop fs -rmr -skipTrash hdfs:///wordcount/overlap$i.txt
	done
	for i in `seq 1 $numOfOverlaps`;
	do		
		~/hadoop-2.7.0/bin/hadoop fs -copyFromLocal -f /dev/app01.txt hdfs:///wordcount/overlap$i.txt &
		# Stop timming	
	done
	wait
	sleep 300
fi

echo "start overlap experiments"

runApp () {
	#$flink/bin/flink run -p 28 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/overlap$i.txt
	#$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 63 -yq -yst $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/overlap$1.txt
	#$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 127 -yq -yst -yjm 1024 -ytm 1024 $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/app02.txt
	$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 63 -yq -yst -yjm 1024 -ytm 1024 -yqu root.sls_queue_$1 $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/app02.txt
	# Stop timming
	date --rfc-3339=seconds >> overlap$2.csv
}

for numLaps in `seq 1 $numOfOverlaps`;
do
	for count in `seq 1 5`;
	do
		date --rfc-3339=seconds >> overlap$numLaps.csv
		for i in `seq 1 $numLaps`;
		do		
			# run the Flink app
			runApp 	$i $numLaps &
		done	
		wait
		sleep 30		
	done
	for server in $serverList; do		
		ssh tanle@$server "sudo rm -rf $yarnAppLogs/*" &
	done
	wait
done
