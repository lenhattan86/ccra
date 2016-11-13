~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-7.txt workGenOutputTestInt-70 -queue interactive0 -map.vcores 2 -red.vcores 2 -map.memory 2048 -red.memory 2048 1.7869763E-5 1.0 >> workGenLogs/interactive-7_0.txt 2>> workGenLogs/interactive-7_0.txt  &  interactive7="$interactive7 $!"  
wait $interactive7 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-70
# inputSize 57303500
