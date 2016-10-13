sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-35.txt workGenOutputTest-350 -queue batch0 1.7869763E-5 27.095703 >> workGenLogs/job-35_0.txt 2>> workGenLogs/job-35_0.txt  &  batch35="$batch35 $!"  
sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-35.txt workGenOutputTest-351 -queue batch1 1.7869763E-5 27.095703 >> workGenLogs/job-35_1.txt 2>> workGenLogs/job-35_1.txt  &  batch35="$batch35 $!"  
wait $batch35 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-350
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-351
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-352
# inputSize 57303500
