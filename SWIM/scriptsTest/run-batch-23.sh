~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-23.txt workGenOutputTest-23 -queue batch1 -map.vcores 4 -red.vcores 1 -map.memory 1024 -red.memory 2048 1.7869763E-5 3.1914062 >> workGenLogs/batch-23.txt 2>> workGenLogs/batch-23.txt  &  batch23=$!  
wait $batch23 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-23
# inputSize 57303500
