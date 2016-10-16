sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-1.txt workGenOutputTest-10 -queue batch0 1.9782387E-4 0.25414607 >> workGenLogs/job-1_0.txt 2>> workGenLogs/job-1_0.txt  &  batch1="$batch1 $!"  
wait $batch1 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-10
# inputSize 57303500
