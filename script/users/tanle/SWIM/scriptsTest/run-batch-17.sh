sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-17.txt workGenOutputTest-170 -queue batch0 1.2676632 0.27645484 >> workGenLogs/job-17_0.txt 2>> workGenLogs/job-17_0.txt  &  batch17="$batch17 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-17.txt workGenOutputTest-171 -queue batch1 1.2676632 0.27645484 >> workGenLogs/job-17_1.txt 2>> workGenLogs/job-17_1.txt  &  batch17="$batch17 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-17.txt workGenOutputTest-172 -queue interactive 1.2676632 0.27645484 >> workGenLogs/job-17_interactive.txt 2>> workGenLogs/job-17.txt   &  batch17="$batch17 $!"  
wait $batch17 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-170
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-171
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-172
# inputSize 68498607
