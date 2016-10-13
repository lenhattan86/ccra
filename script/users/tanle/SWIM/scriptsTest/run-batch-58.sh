sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-58.txt workGenOutputTest-580 -queue batch0 3.5216E-5 0.5074331 >> workGenLogs/job-58_0.txt 2>> workGenLogs/job-58_0.txt  &  batch58="$batch58 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-58.txt workGenOutputTest-581 -queue batch1 3.5216E-5 0.5074331 >> workGenLogs/job-58_1.txt 2>> workGenLogs/job-58_1.txt  &  batch58="$batch58 $!"  
wait $batch58 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-580
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-581
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-582
# inputSize 57303500
