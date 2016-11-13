~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-33.txt workGenOutputTest-33 -queue batch1 -map.vcores 6 -red.vcores 5 -map.memory 2048 -red.memory 1024 1.7869763E-5 2.7167969 >> workGenLogs/batch-33.txt 2>> workGenLogs/batch-33.txt  &  batch33=$!  
wait $batch33 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-33
# inputSize 57303500
