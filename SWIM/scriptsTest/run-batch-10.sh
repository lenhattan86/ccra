sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-10.txt workGenOutputTest-100 -queue batch0 -memory 1024 1.7869763E-5 1.0 >> workGenLogs/batch-10_0.txt 2>> workGenLogs/batch-10_0.txt  &  batch10="$batch10 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-10.txt workGenOutputTest-101 -queue batch1 -memory 1024 1.7869763E-5 1.0 >> workGenLogs/batch-10_1.txt 2>> workGenLogs/batch-10_1.txt  &  batch10="$batch10 $!"  
wait $batch10 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-100
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-101
# inputSize 57303500
