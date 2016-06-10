# Start timming
#flink="../../build-target"
flink="../../flink-1.0.3"
#rm -rf app01.csv
sleep 120
for i in `seq 1 3`;	
do
	date --rfc-3339=seconds >> app01.csv
	# run the Flink app
	$flink/bin/flink run -p 64 $flink/examples/streaming/WordCount.jar --input hdfs:///wordcount/app01.txt 
	# Stop timming
	date --rfc-3339=seconds >> app01.csv        
	sleep 360
done  

