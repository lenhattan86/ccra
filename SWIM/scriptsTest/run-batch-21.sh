~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-21.txt workGenOutputTest-21 -queue batch1 -map.vcores 2 -red.vcores 3 -map.memory 2048 -red.memory 4096 5.900163E-5 0.30286896 >> workGenLogs/batch-21.txt 2>> workGenLogs/batch-21.txt  &  batch21=$!  
wait $batch21 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-21
# inputSize 57303500
