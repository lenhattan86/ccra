sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-26.txt workGenOutputTest-260 -queue batch0 5.5389287E-4 0.1689666 >> workGenLogs/job-26_0.txt 2>> workGenLogs/job-26_0.txt  &  batch26="$batch26 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-26.txt workGenOutputTest-261 -queue batch1 5.5389287E-4 0.1689666 >> workGenLogs/job-26_1.txt 2>> workGenLogs/job-26_1.txt  &  batch26="$batch26 $!"  
wait $batch26 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-260
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-261
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-262
# inputSize 57303500
