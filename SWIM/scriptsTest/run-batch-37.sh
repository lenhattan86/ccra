~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 9 inputPath-batch-37.txt workGenOutputTest-37 -queue batch1 -map.vcores 4 -red.vcores 4 -map.memory 3072 -red.memory 2048 1.7869763E-5 597539.3 >> workGenLogs/batch-37.txt 2>> workGenLogs/batch-37.txt  &  batch37=$!  
wait $batch37 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-37
# inputSize 57303500
