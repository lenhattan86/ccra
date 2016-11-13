~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-36.txt workGenOutputTest-36 -queue batch0 -map.vcores 4 -red.vcores 2 -map.memory 2048 -red.memory 4096 1.7869763E-5 17643.303 >> workGenLogs/batch-36.txt 2>> workGenLogs/batch-36.txt  &  batch36=$!  
wait $batch36 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-36
# inputSize 57303500
