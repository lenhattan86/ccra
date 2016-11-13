~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-3.txt workGenOutputTestInt-30 -queue interactive0 -map.vcores 2 -red.vcores 2 -map.memory 2048 -red.memory 2048 1.7869763E-5 1.0 >> workGenLogs/interactive-3_0.txt 2>> workGenLogs/interactive-3_0.txt  &  interactive3="$interactive3 $!"  
wait $interactive3 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-30
# inputSize 57303500
