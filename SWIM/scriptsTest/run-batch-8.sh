~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-8.txt workGenOutputTest-8 -queue batch0 -map.vcores 6 -red.vcores 3 -map.memory 2048 -red.memory 2048 0.003094872 0.21065482 >> workGenLogs/batch-8.txt 2>> workGenLogs/batch-8.txt  &  batch8=$!  
wait $batch8 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-8
# inputSize 57303500
