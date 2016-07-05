# Start timming
yarnAppLogs="/dev/shm/yarn-logs"
serverList="nm cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
flink="$HOME/flink-1.0.3"

numberOfTasks=79
className="cpubound.IterateExample"
folder="cpubound-log"
timestampFile="$folder/cpubound"

rm -rf $folder
mkdir $folder

numOfOverlaps=4
numOfExp=5
isCopy=false

for server in $serverList; do		
	ssh tanle@$server "sudo rm -rf $yarnAppLogs/*" &
done

echo "start overlap experiments"

runAppOnDifferentQueues () {
	if [ `expr $1 % 2` -eq 0 ]
	then
	    queueName="root.sls_queue_4"
	else
	    queueName="root.sls_queue_3"	 	
	fi
	# run the Flink app
	#$HOME/flink-1.0.3/bin/flink run -c cpubound.IterateExample -m yarn-cluster -yn 319 -yq -yst -yqu root.sls_queue_3 $HOME/flink-run/flink-target/cpu-bound-0.1.jar --output hdfs:///cpubound/cpubound1.out
	$HOME/flink-1.0.3/bin/flink run -c $className -m yarn-cluster -yn $numberOfTasks -yq -yst -yqu $queueName $HOME/flink-run/flink-target/cpu-bound-0.1.jar --log $timestampFile$2_$1.csv
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

runAppOnTheSameQueue () {	
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
	# run the Flink app
	$HOME/flink-1.0.3/bin/flink run -c $className -m yarn-cluster -yn $numberOfTasks -yq -yst -yqu root.sls_queue_3 $HOME/flink-run/flink-target/cpu-bound-0.1.jar --log $timestampFile$2_$1.csv
	# Stop timming
	date --rfc-3339=seconds >> $timestampFile$2_$1.csv
}

for numLaps in `seq 1 $numOfOverlaps`;
do
	for count in `seq 1 $numOfExp`;
	do
		
		for i in `seq 1 $numLaps`;
		do		
			# run the Flink app
			runAppOnTheSameQueue	$i $numLaps &
			#runAppOnDifferentQueues	$i $numLaps &
		done	
		wait
		sleep 15		
	done
	for server in $serverList; do		
		ssh tanle@$server "sudo rm -rf $yarnAppLogs/*" &
	done
	wait
done

