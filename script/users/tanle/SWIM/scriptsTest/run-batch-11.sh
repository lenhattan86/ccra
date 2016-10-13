sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-11.txt workGenOutputTest-110 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-11_0.txt 2>> workGenLogs/job-11_0.txt  &  batch11="$batch11 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-11.txt workGenOutputTest-111 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-11_1.txt 2>> workGenLogs/job-11_1.txt  &  batch11="$batch11 $!"  
wait $batch11 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-110
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-111
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-112
# inputSize 57303500
