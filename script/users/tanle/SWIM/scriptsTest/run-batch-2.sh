sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-2.txt workGenOutputTest-20 -queue batch0 6.914063E-5 0.39273095 >> workGenLogs/job-2_0.txt 2>> workGenLogs/job-2_0.txt  &  batch2="$batch2 $!"  
wait $batch2 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-20
# inputSize 57303500
