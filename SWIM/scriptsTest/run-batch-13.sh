~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-13.txt workGenOutputTest-13 -queue batch1 -map.vcores 6 -red.vcores 2 -map.memory 3072 -red.memory 3072 1.7869763E-5 1.0 >> workGenLogs/batch-13.txt 2>> workGenLogs/batch-13.txt  &  batch13=$!  
wait $batch13 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-13
# inputSize 57303500
