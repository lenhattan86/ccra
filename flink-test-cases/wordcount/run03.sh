# Start timming
#flink="../../build-target"
flink="../../flink-1.0.3"
#rm -rf app03.csv
for i in `seq 1 30`;
do
	date --rfc-3339=seconds >> app03.csv
	# run the Flink app
	$flink/bin/flink run -p 64 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/app03.txt
	# Stop timming
	date --rfc-3339=seconds >> app03.csv
	sleep 45
done
