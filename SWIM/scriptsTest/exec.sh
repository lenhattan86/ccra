#!/bin/bash
rm -r workGenLogs
mkdir workGenLogs
server="$(hostname)" 
if [ "$server" == "tan-ubuntu" ]; then
	 server="localhost" 
fi 

python ../get_yarn_queue_info.py --master $server --interval 1 --file workGenLogs/yarnUsedResources.csv & pythonScript=$! 
./batches-all.sh & runBatches=$! 
sleep 100 
./interactives-all.sh & runInteractives=$! 
wait $runBatches ; 
wait $runInteractives; 

sleep 100; kill $pythonScript
echo "[INFO] Finished at: $(date)" 