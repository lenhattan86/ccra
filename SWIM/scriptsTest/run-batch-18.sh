~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-18.txt workGenOutputTest-18 -queue batch0 -map.vcores 6 -red.vcores 4 -map.memory 2048 -red.memory 3072 6.678475E-5 0.26757252 >> workGenLogs/batch-18.txt 2>> workGenLogs/batch-18.txt  &  batch18=$!  
wait $batch18 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-18
# inputSize 57303500
