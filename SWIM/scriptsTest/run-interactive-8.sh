~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-8.txt workGenOutputTestInt-80 -queue interactive0 -map.vcores 2 -red.vcores 2 -map.memory 2048 -red.memory 2048 1.7869763E-5 1.0 >> workGenLogs/interactive-8_0.txt 2>> workGenLogs/interactive-8_0.txt  &  interactive8="$interactive8 $!"  
wait $interactive8 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-80
# inputSize 57303500
