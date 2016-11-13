~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-12.txt workGenOutputTest-12 -queue batch0 -map.vcores 5 -red.vcores 3 -map.memory 2048 -red.memory 5120 0.0027066933 0.0066020642 >> workGenLogs/batch-12.txt 2>> workGenLogs/batch-12.txt  &  batch12=$!  
wait $batch12 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-12
# inputSize 57303500
