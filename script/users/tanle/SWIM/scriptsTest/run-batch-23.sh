sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-23.txt workGenOutputTest-230 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-23_0.txt 2>> workGenLogs/job-23_0.txt  &  batch23="$batch23 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-23.txt workGenOutputTest-231 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-23_1.txt 2>> workGenLogs/job-23_1.txt  &  batch23="$batch23 $!"  
wait $batch23 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-230
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-231
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-232
# inputSize 57303500
