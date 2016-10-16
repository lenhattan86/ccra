sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-7.txt workGenOutputTest-70 -queue batch0 2.982366E-5 0.5991808 >> workGenLogs/job-7_0.txt 2>> workGenLogs/job-7_0.txt  &  batch7="$batch7 $!"  
wait $batch7 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-70
# inputSize 57303500
