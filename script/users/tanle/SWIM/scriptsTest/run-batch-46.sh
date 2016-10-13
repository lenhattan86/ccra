sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-46.txt workGenOutputTest-460 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-46_0.txt 2>> workGenLogs/job-46_0.txt  &  batch46="$batch46 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-46.txt workGenOutputTest-461 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-46_1.txt 2>> workGenLogs/job-46_1.txt  &  batch46="$batch46 $!"  
wait $batch46 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-460
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-461
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-462
# inputSize 57303500
