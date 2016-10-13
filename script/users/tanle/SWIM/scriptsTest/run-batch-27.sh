sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-27.txt workGenOutputTest-270 -queue batch0 8.695455E-4 0.107630245 >> workGenLogs/job-27_0.txt 2>> workGenLogs/job-27_0.txt  &  batch27="$batch27 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-27.txt workGenOutputTest-271 -queue batch1 8.695455E-4 0.107630245 >> workGenLogs/job-27_1.txt 2>> workGenLogs/job-27_1.txt  &  batch27="$batch27 $!"  
wait $batch27 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-270
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-271
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-272
# inputSize 57303500
