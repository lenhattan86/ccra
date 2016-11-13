#!/bin/bash
rm -r workGenLogs
mkdir workGenLogs

python ../get_yarn_queue_info.py --master $(hostname) --interval 1 --file workGenLogs/yarnUsedResources.csv & pythonScript=$! 
./batches-all.sh & runBatches=$! 
./interactives-all.sh & runInteractives=$! 
wait $runBatches ; wait $runInteractives; sleep 240 
