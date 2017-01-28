defaulHostname="ctl.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us"

#defaultDomain="yarnrm-pg0.utah.cloudlab.us"
defaultDomain="yarnrm-pg0.clemson.cloudlab.us"



if [ -z "$1" ]
then
	hostname=$defaulHostname
else
	hostname="ctl.$1.$defaultDomain"
fi

if [ -z "$2" ]
then
	batchNum=4
else
	batchNum=$2
fi

workloadSrcFile="/home/tanle/projects/SpeedFairSim/input/jobs_input_1_$batchNum.txt"
#workloadSrcFile="/home/tanle/projects/SpeedFairSim/input_gen/jobs_input_1_1_40_BB_mov.txt"
workloadFile="/users/tanle/hadoop/conf/simple.txt"

echo "upload the files to $hostname"

prompt () {
	while true; do
	    read -p "Do you wish to upload new test cases onto $hostname?" yn
	    case $yn in
		[Yy]* ) make install; break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	    esac
	done
}

uploadTestCases () {
	echo "upload $2 ................"
	tar zcvf $1.tar $2
	ssh tanle@$hostname "rm -rf $1.tar; rm -rf $1;"
	scp $1.tar $hostname:~/ 
	sleep 2
	ssh tanle@$hostname "tar -xvzf $1.tar"
	rm -rf $1.tar
	ssh tanle@$hostname "rm -rf $1.tar;"
}

#prompt

tarFile="SWIM"; testCase="../SWIM"; rm -rf .$testCase/*.class; uploadTestCases $tarFile $testCase &

ssh tanle@$hostname "hadoop/bin/hadoop fs -rm -skipTrash /user/tanle/completion_time.csv;"
ssh tanle@$hostname "hadoop/bin/hadoop fs -rm -skipTrash /user/tanle/tez_container_time.csv;"

scp $workloadSrcFile  $hostname:$workloadFile
ssh tanle@$hostname "cd hadoop/conf; rm -rf *.profile; javac GenerateProfile.java; java GenerateProfile $workloadFile"

#tarFile="spark-test-cases"; testCase="../spark-test-cases"; uploadTestCases $tarFile $testCase &

#tarFile="wordcount"; testCase="../flink-test-cases/wordcount"; uploadTestCases $tarFile $testCase &

wait

echo "[INFO] $hostname "
echo "[INFO] Finished at: $(date) "
