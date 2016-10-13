sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-36.txt workGenOutputTest-360 -queue batch0 1.7869763E-5 1764.3301 >> workGenLogs/job-36_0.txt 2>> workGenLogs/job-36_0.txt  &  batch36="$batch36 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-36.txt workGenOutputTest-361 -queue batch1 1.7869763E-5 1764.3301 >> workGenLogs/job-36_1.txt 2>> workGenLogs/job-36_1.txt  &  batch36="$batch36 $!"  
wait $batch36 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-360
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-361
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-362
# inputSize 57303500
