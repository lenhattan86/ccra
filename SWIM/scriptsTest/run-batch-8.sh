sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-8.txt workGenOutputTest-80 -queue batch0 -memory 1024 3.09475E-4 0.21061239 >> workGenLogs/batch-8_0.txt 2>> workGenLogs/batch-8_0.txt  &  batch8="$batch8 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-8.txt workGenOutputTest-81 -queue batch1 -memory 1024 3.09475E-4 0.21061239 >> workGenLogs/batch-8_1.txt 2>> workGenLogs/batch-8_1.txt  &  batch8="$batch8 $!"  
wait $batch8 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-80
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-81
# inputSize 57303500
