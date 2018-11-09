HADOOP_HOME=~/hadoop
isGenScripts=false

cp randomwriter_conf.xsl ~/hadoop/config

yarnAppLogs="/dev/shm/yarn-logs"
serverList="ctl cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8"
for server in $serverList; do		
	ssh $server "sudo rm -rf $yarnAppLogs/*" &
done

rm *.class

# test
rm -rf hdfsWrite; mkdir hdfsWrite; javac -classpath $HADOOP_HOME/share/hadoop/common/\*:$HADOOP_HOME/share/hadoop/mapreduce/\*:$HADOOP_HOME/share/hadoop/mapreduce/lib/\* -d hdfsWrite HDFSWrite.java; jar -cvf HDFSWrite.jar -C hdfsWrite/ .

~/hadoop/bin/hadoop fs -rm -r -skipTrash hdfs:///user/tanle/workGenInput; ~/hadoop/bin/hadoop jar HDFSWrite.jar org.apache.hadoop.examples.HDFSWrite -conf ~/hadoop/conf/randomwriter_conf.xsl workGenInput batch0 & prepareInput=$!

# Compile MapReduce jobs

if $isGenScripts
then
	rm -rf workGen; mkdir workGen; javac -classpath $HADOOP_HOME/share/hadoop/common/\*:$HADOOP_HOME/share/hadoop/mapreduce/\*:$HADOOP_HOME/share/hadoop/mapreduce/lib/\* -d workGen WorkGen.java; jar -cvf WorkGen.jar -C workGen/ .

	rm -rf scriptTest; javac  GenerateReplayScript.java; java GenerateReplayScript

	javac GenerateSparkScripts.java; java GenerateSparkScripts
fi

wait $prepareInput

#~/hadoop/bin/hadoop fs -ls hdfs:///user/tanle/workGenInput
