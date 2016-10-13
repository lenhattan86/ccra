sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 0 inputPath-batch-57.txt workGenOutputTest-570 -queue batch0 1.7869763E-5 559240.56 >> workGenLogs/job-57_0.txt 2>> workGenLogs/job-57_0.txt  &  batch57="$batch57 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 0 inputPath-batch-57.txt workGenOutputTest-571 -queue batch1 1.7869763E-5 559240.56 >> workGenLogs/job-57_1.txt 2>> workGenLogs/job-57_1.txt  &  batch57="$batch57 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 0 inputPath-batch-57.txt workGenOutputTest-572 -queue interactive 1.7869763E-5 559240.56 >> workGenLogs/job-57_interactive.txt 2>> workGenLogs/job-57.txt   &  batch57="$batch57 $!"  
wait $batch57 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-570
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-571
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-572
# inputSize 57303500
