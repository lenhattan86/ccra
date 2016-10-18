sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-0.txt workGenOutputTest-00 -queue batch0 -memory 1024 2.7218234E-4 0.2681926 >> workGenLogs/batch-0_0.txt 2>> workGenLogs/batch-0_0.txt  &  batch0="$batch0 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-0.txt workGenOutputTest-01 -queue batch1 -memory 1024 2.7218234E-4 0.2681926 >> workGenLogs/batch-0_1.txt 2>> workGenLogs/batch-0_1.txt  &  batch0="$batch0 $!"  
wait $batch0 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-00
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-01
# inputSize 57303500
