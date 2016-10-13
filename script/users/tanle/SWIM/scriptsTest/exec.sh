#!/bin/bash
rm -r workGenLogs
mkdir workGenLogs

python ../get_yarn_queue_info.py --master nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us --interval 1 --file workGenLogs/yarnUsedResources.csv & pythonScript=$! 
./batches-all.sh & runBatches=$! 
wait $runBatches 

 kill $pythonScript
