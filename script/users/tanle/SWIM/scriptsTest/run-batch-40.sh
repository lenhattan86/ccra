sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 3 inputPath-batch-40.txt workGenOutputTest-400 -queue batch0 1.7869763E-5 167988.48 >> workGenLogs/job-40_0.txt 2>> workGenLogs/job-40_0.txt  &  batch40="$batch40 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 3 inputPath-batch-40.txt workGenOutputTest-401 -queue batch1 1.7869763E-5 167988.48 >> workGenLogs/job-40_1.txt 2>> workGenLogs/job-40_1.txt  &  batch40="$batch40 $!"  
wait $batch40 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-400
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-401
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-402
# inputSize 57303500
