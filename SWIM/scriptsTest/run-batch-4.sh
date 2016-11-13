~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-4.txt workGenOutputTest-4 -queue batch0 -map.vcores 5 -red.vcores 1 -map.memory 3072 -red.memory 2048 1.7869763E-5 640.49805 >> workGenLogs/batch-4.txt 2>> workGenLogs/batch-4.txt  &  batch4=$!  
wait $batch4 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-4
# inputSize 57303500
