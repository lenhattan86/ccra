sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-55.txt workGenOutputTest-550 -queue batch0 1.7869763E-5 8613.415 >> workGenLogs/job-55_0.txt 2>> workGenLogs/job-55_0.txt  &  batch55="$batch55 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-55.txt workGenOutputTest-551 -queue batch1 1.7869763E-5 8613.415 >> workGenLogs/job-55_1.txt 2>> workGenLogs/job-55_1.txt  &  batch55="$batch55 $!"  
wait $batch55 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-550
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-551
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-552
# inputSize 57303500
