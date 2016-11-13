~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-1.txt workGenOutputTestInt-10 -queue interactive0 -map.vcores 2 -red.vcores 2 -map.memory 2048 -red.memory 2048 1.8145489E-4 0.26812848 >> workGenLogs/interactive-1_0.txt 2>> workGenLogs/interactive-1_0.txt  &  interactive1="$interactive1 $!"  
wait $interactive1 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-10
# inputSize 57303500
