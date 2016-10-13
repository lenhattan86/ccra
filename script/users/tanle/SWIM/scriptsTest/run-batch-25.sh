sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-25.txt workGenOutputTest-250 -queue batch0 0.005211514 1.6002485 >> workGenLogs/job-25_0.txt 2>> workGenLogs/job-25_0.txt  &  batch25="$batch25 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-25.txt workGenOutputTest-251 -queue batch1 0.005211514 1.6002485 >> workGenLogs/job-25_1.txt 2>> workGenLogs/job-25_1.txt  &  batch25="$batch25 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-25.txt workGenOutputTest-252 -queue interactive 0.005211514 1.6002485 >> workGenLogs/job-25_interactive.txt 2>> workGenLogs/job-25.txt   &  batch25="$batch25 $!"  
wait $batch25 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-250
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-251
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-252
# inputSize 57303500
