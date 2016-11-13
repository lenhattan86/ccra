~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 9 inputPath-batch-39.txt workGenOutputTest-39 -queue batch1 -map.vcores 4 -red.vcores 6 -map.memory 1024 -red.memory 2048 1.7869763E-5 574609.6 >> workGenLogs/batch-39.txt 2>> workGenLogs/batch-39.txt  &  batch39=$!  
wait $batch39 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-39
# inputSize 57303500
