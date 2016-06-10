# Start timming
#flink="../../build-target"
flink="$HOME/flink-1.0.3"
rm -rf overlap.csv
numOfOverlaps=7
isCopy=true

if $isCopy
then
	echo "copy files"
	for i in `seq 1 $numOfOverlaps`;
	do		
		# run the Flink app
		~/hadoop-2.7.0/bin/hadoop fs -copyFromLocal -f /dev/app03.txt hdfs:///wordcount/overlap$i.txt &
		# Stop timming	
	done
	wait
	sleep 15
fi
echo "start overlap experiments"

for numLaps in `seq 1 $numOfOverlaps`;
do
	for i in `seq 1 30`;
	do
		date --rfc-3339=seconds >> overlap$numLaps.csv
		for i in `seq 1 $numLaps`;
		do		
			# run the Flink app
			$flink/bin/flink run -p 56 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/overlap$i.txt &
			# Stop timming	
		done	
		wait
		date --rfc-3339=seconds >> overlap$numLaps.csv
		sleep 15
	done
done
