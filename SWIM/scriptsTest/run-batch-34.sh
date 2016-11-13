~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 19 inputPath-batch-34.txt workGenOutputTest-34 -queue batch0 -map.vcores 4 -red.vcores 4 -map.memory 2048 -red.memory 3072 1.7869763E-5 1218940.5 >> workGenLogs/batch-34.txt 2>> workGenLogs/batch-34.txt  &  batch34=$!  
wait $batch34 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-34
# inputSize 57303500
