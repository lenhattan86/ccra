sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-21.txt workGenOutputTest-210 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-21_0.txt 2>> workGenLogs/job-21_0.txt  &  batch21="$batch21 $!"  
sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-21.txt workGenOutputTest-211 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-21_1.txt 2>> workGenLogs/job-21_1.txt  &  batch21="$batch21 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-21.txt workGenOutputTest-212 -queue interactive 1.7869763E-5 1.0 >> workGenLogs/job-21_interactive.txt 2>> workGenLogs/job-21.txt   &  batch21="$batch21 $!"  
wait $batch21 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-210
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-211
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-212
# inputSize 57303500
