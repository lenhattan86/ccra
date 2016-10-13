sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-39.txt workGenOutputTest-390 -queue batch0 1.7869763E-5 57460.96 >> workGenLogs/job-39_0.txt 2>> workGenLogs/job-39_0.txt  &  batch39="$batch39 $!"  
sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-39.txt workGenOutputTest-391 -queue batch1 1.7869763E-5 57460.96 >> workGenLogs/job-39_1.txt 2>> workGenLogs/job-39_1.txt  &  batch39="$batch39 $!"  
wait $batch39 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-390
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-391
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-392
# inputSize 57303500
