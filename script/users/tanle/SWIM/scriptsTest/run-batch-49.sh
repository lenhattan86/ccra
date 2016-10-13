sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-49.txt workGenOutputTest-490 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-49_0.txt 2>> workGenLogs/job-49_0.txt  &  batch49="$batch49 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-49.txt workGenOutputTest-491 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-49_1.txt 2>> workGenLogs/job-49_1.txt  &  batch49="$batch49 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-49.txt workGenOutputTest-492 -queue interactive 1.7869763E-5 1.0 >> workGenLogs/job-49_interactive.txt 2>> workGenLogs/job-49.txt   &  batch49="$batch49 $!"  
wait $batch49 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-490
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-491
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-492
# inputSize 57303500
