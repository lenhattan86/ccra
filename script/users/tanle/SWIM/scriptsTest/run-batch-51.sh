sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-51.txt workGenOutputTest-510 -queue batch0 6.3713385E-5 0.4368666 >> workGenLogs/job-51_0.txt 2>> workGenLogs/job-51_0.txt  &  batch51="$batch51 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-51.txt workGenOutputTest-511 -queue batch1 6.3713385E-5 0.4368666 >> workGenLogs/job-51_1.txt 2>> workGenLogs/job-51_1.txt  &  batch51="$batch51 $!"  
wait $batch51 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-510
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-511
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-512
# inputSize 57303500
