~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-2.txt workGenOutputTest-2 -queue batch0 -map.vcores 1 -red.vcores 6 -map.memory 1024 -red.memory 3072 6.914063E-4 0.3929581 >> workGenLogs/batch-2.txt 2>> workGenLogs/batch-2.txt  &  batch2=$!  
wait $batch2 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-2
# inputSize 57303500
