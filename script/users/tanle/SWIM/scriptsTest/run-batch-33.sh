sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-33.txt workGenOutputTest-330 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-33_0.txt 2>> workGenLogs/job-33_0.txt  &  batch33="$batch33 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-33.txt workGenOutputTest-331 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-33_1.txt 2>> workGenLogs/job-33_1.txt  &  batch33="$batch33 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-33.txt workGenOutputTest-332 -queue interactive 1.7869763E-5 1.0 >> workGenLogs/job-33_interactive.txt 2>> workGenLogs/job-33.txt   &  batch33="$batch33 $!"  
wait $batch33 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-330
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-331
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-332
# inputSize 57303500
