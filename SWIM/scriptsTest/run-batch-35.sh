~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-35.txt workGenOutputTest-35 -queue batch1 -map.vcores 5 -red.vcores 6 -map.memory 2048 -red.memory 1024 1.7869763E-5 270.96484 >> workGenLogs/batch-35.txt 2>> workGenLogs/batch-35.txt  &  batch35=$!  
wait $batch35 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-35
# inputSize 57303500
