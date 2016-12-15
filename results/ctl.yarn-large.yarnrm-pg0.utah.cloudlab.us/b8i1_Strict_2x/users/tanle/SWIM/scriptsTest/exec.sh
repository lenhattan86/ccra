#!/bin/bash
rm -r workGenLogs
mkdir workGenLogs
server="$(hostname)" 
if [ "$server" == "tan-ubuntu" ]; then
	 server="localhost" 
fi 

python ../get_yarn_queue_info.py --master $server --interval 1 --file workGenLogs/yarnUsedResources.csv & pythonScript=$! 
./batches-all.sh & runBatches=$! 
sleep 200 
./interactives-all.sh & runInteractives=$! 
wait $runBatches ; 

kill $runInteractives
sleep 200; kill $pythonScript
 ~/hadoop/bin/yarn application -kill all
echo "[INFO] Finished at: $(date)" 