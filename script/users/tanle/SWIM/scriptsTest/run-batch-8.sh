sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-8.txt workGenOutputTest-80 -queue batch0 3.09475E-4 0.21061239 >> workGenLogs/job-8_0.txt 2>> workGenLogs/job-8_0.txt  &  batch8="$batch8 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-8.txt workGenOutputTest-81 -queue batch1 3.09475E-4 0.21061239 >> workGenLogs/job-8_1.txt 2>> workGenLogs/job-8_1.txt  &  batch8="$batch8 $!"  
wait $batch8 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-80
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-81
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-82
# inputSize 57303500
