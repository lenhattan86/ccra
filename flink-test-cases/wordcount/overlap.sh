# Start timming
#flink="../../build-target"
flink="$HOME/flink-1.0.3"
rm -rf overlap.csv
numOfOverlaps=5
isCopy=false

if $isCopy
then
	echo "copy files"
	for i in `seq 1 2 $numOfOverlaps`;
	do		
		# run the Flink app
		~/hadoop-2.7.0/bin/hadoop fs -copyFromLocal -f /dev/app03.txt hdfs:///wordcount/overlap$i.txt &
		# Stop timming	
	done
	wait
	sleep 15
fi
echo "start overlap experiments"

for numLaps in `seq 3 2 $numOfOverlaps`;
do
	for j in `seq 1 2`;
	do
		date --rfc-3339=seconds >> overlap$numLaps.csv
		for i in `seq 1 $numLaps`;
		do		
			# run the Flink app
			#$flink/bin/flink run -p 28 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/overlap$i.txt &
			$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 150 -yd -yq -yst $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/app03.txt & 
			# Stop timming	
		done	
		wait
		date --rfc-3339=seconds >> overlap$numLaps.csv
		sleep 50
	done
done
