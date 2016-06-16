# Start timming
#flink="../../build-target"
flink="$HOME/flink-1.0.3"
#rm -rf app03.csv
queueName="root.sls_queue_1"
for i in `seq 1 2`;
do
	date --rfc-3339=seconds >> app03.csv
	# run the Flink app
	#$flink/bin/flink run -yqu $queueName -p 64 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/app03.txt
	$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 63 -yd -yq -yst $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/app03.txt
	# Stop timming
	date --rfc-3339=seconds >> app03.csv
	sleep 30
done
