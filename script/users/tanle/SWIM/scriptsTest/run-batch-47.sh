sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-47.txt workGenOutputTest-470 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-47_0.txt 2>> workGenLogs/job-47_0.txt  &  batch47="$batch47 $!"  
sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-47.txt workGenOutputTest-471 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-47_1.txt 2>> workGenLogs/job-47_1.txt  &  batch47="$batch47 $!"  
wait $batch47 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-470
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-471
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-472
# inputSize 57303500
