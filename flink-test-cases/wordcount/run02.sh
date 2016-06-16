# Start timming
#flink="../../build-target"
flink="$HOME/flink-1.0.3"
#rm -rf app02.csv
sleep 60
for i in `seq 1 3`;
do
	date --rfc-3339=seconds >> app02.log
	# run the Flink app
	#$flink/bin/flink run -p 64 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/app02.txt
	$HOME/flink-1.0.3/bin/flink run -m yarn-cluster -yn 63 -yd -yq -yst $HOME/flink-1.0.3/examples/streaming/WordCount.jar --input hdfs:///wordcount/app02.txt
	# Stop timming
	date --rfc-3339=seconds >> app02.csv
	sleep 30
done
