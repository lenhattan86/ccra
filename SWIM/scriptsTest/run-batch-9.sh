~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-9.txt workGenOutputTest-9 -queue batch1 -map.vcores 2 -red.vcores 6 -map.memory 2048 -red.memory 7168 0.0027561493 0.4087136 >> workGenLogs/batch-9.txt 2>> workGenLogs/batch-9.txt  &  batch9=$!  
wait $batch9 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-9
# inputSize 57303500
