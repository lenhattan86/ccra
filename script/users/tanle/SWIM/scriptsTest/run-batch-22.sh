sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-22.txt workGenOutputTest-220 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-22_0.txt 2>> workGenLogs/job-22_0.txt  &  batch22="$batch22 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-22.txt workGenOutputTest-221 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-22_1.txt 2>> workGenLogs/job-22_1.txt  &  batch22="$batch22 $!"  
wait $batch22 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-220
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-221
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-222
# inputSize 57303500
