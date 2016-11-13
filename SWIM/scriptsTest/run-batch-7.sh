~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-7.txt workGenOutputTest-7 -queue batch1 -map.vcores 2 -red.vcores 5 -map.memory 1024 -red.memory 4096 2.9835873E-4 0.05989355 >> workGenLogs/batch-7.txt 2>> workGenLogs/batch-7.txt  &  batch7=$!  
wait $batch7 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-7
# inputSize 57303500
