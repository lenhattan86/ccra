~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 17 inputPath-batch-17.txt workGenOutputTest-17 -queue batch1 -map.vcores 5 -red.vcores 6 -map.memory 2048 -red.memory 6144 1.2676634 0.2764548 >> workGenLogs/batch-17.txt 2>> workGenLogs/batch-17.txt  &  batch17=$!  
wait $batch17 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-17
# inputSize 684986073
