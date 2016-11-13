~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-27.txt workGenOutputTest-27 -queue batch1 -map.vcores 6 -red.vcores 6 -map.memory 1024 -red.memory 7168 0.008695525 0.10764343 >> workGenLogs/batch-27.txt 2>> workGenLogs/batch-27.txt  &  batch27=$!  
wait $batch27 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-27
# inputSize 57303500
