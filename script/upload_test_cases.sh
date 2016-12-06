defaulHostname="ctl.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="c220g1-030826.wisc.cloudlab.us" #drf

defaultDomain="yarnrm-pg0.wisc.cloudlab.us"

workloadSrcFile="/home/tanle/projects/SpeedFairSim/input_gen/jobs_input_1_3.txt"
#workloadSrcFile="/home/tanle/projects/SpeedFairSim/input_gen/jobs_input_1_3_short.txt"
workloadFile="/users/tanle/hadoop/conf/simple.txt"
#workloadFile="/users/tanle/conf/simple.txt"

echo "upload the files to $hostname"

if [ -z "$1" ]
then
	hostname=$defaulHostname
else
	hostname="ctl.$1.$defaultDomain"
fi

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

scp $workloadSrcFile  $hostname:$workloadFile

#tarFile="spark-test-cases"; testCase="../spark-test-cases"; uploadTestCases $tarFile $testCase &

#tarFile="wordcount"; testCase="../flink-test-cases/wordcount"; uploadTestCases $tarFile $testCase &

wait

