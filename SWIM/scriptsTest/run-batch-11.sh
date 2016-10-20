sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-11.txt workGenOutputTest-110 -queue batch0 -memory 1024 1.7869763E-5 1.0 >> workGenLogs/batch-11_0.txt 2>> workGenLogs/batch-11_0.txt  &  batch11="$batch11 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-11.txt workGenOutputTest-111 -queue batch1 -memory 1024 1.7869763E-5 1.0 >> workGenLogs/batch-11_1.txt 2>> workGenLogs/batch-11_1.txt  &  batch11="$batch11 $!"  
wait $batch11 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-110
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-111
# inputSize 57303500