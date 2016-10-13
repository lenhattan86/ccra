sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-48.txt workGenOutputTest-480 -queue batch0 1.4105596E-4 0.12668563 >> workGenLogs/job-48_0.txt 2>> workGenLogs/job-48_0.txt  &  batch48="$batch48 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-48.txt workGenOutputTest-481 -queue batch1 1.4105596E-4 0.12668563 >> workGenLogs/job-48_1.txt 2>> workGenLogs/job-48_1.txt  &  batch48="$batch48 $!"  
wait $batch48 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-480
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-481
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-482
# inputSize 57303500
