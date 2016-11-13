~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 3 inputPath-batch-19.txt workGenOutputTest-19 -queue batch1 -map.vcores 1 -red.vcores 5 -map.memory 1024 -red.memory 4096 0.574622 3.9514707E-4 >> workGenLogs/batch-19.txt 2>> workGenLogs/batch-19.txt  &  batch19=$!  
wait $batch19 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-19
# inputSize 318430974
