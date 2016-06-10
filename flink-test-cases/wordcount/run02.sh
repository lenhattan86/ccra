# Start timming
#flink="../../build-target"
flink="../../flink-1.0.3"
#rm -rf app02.csv
sleep 60
for i in `seq 1 3`;
do
	date --rfc-3339=seconds >> app02.log
	# run the Flink app
	$flink/bin/flink run -p 64 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/app02.txt
	# Stop timming
	date --rfc-3339=seconds >> app02.csv
	sleep 360
done
