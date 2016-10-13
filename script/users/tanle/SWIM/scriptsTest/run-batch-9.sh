sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-9.txt workGenOutputTest-90 -queue batch0 2.756027E-4 0.40872538 >> workGenLogs/job-9_0.txt 2>> workGenLogs/job-9_0.txt  &  batch9="$batch9 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-9.txt workGenOutputTest-91 -queue batch1 2.756027E-4 0.40872538 >> workGenLogs/job-9_1.txt 2>> workGenLogs/job-9_1.txt  &  batch9="$batch9 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-9.txt workGenOutputTest-92 -queue interactive 2.756027E-4 0.40872538 >> workGenLogs/job-9_interactive.txt 2>> workGenLogs/job-9.txt   &  batch9="$batch9 $!"  
wait $batch9 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-90
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-91
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-92
# inputSize 57303500
