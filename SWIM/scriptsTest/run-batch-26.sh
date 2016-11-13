~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-26.txt workGenOutputTest-26 -queue batch0 -map.vcores 3 -red.vcores 5 -map.memory 3072 -red.memory 3072 0.005539051 0.16898493 >> workGenLogs/batch-26.txt 2>> workGenLogs/batch-26.txt  &  batch26=$!  
wait $batch26 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-26
# inputSize 57303500
