defaulHostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="c220g1-030826.wisc.cloudlab.us" #drf
serverList="cp-1 cp-2 cp-3 cp-4  cp-5  cp-6  cp-4 cp-4 cp-4 cp-4 cp-4 cp-10"
counter=0
PARALLEL=4
for server in $serverList; do
	counter=$((counter+1))
	echo $server; sleep 10 &		
	if [[ "$counter" -gt $PARALLEL ]]; then
       		counter=0;
		wait
       	fi
done

echo "upload the files to $hostname"

if [ -z "$1" ]
then
	hostname=$defaulHostname
else
	hostname="nm.$1.yarnrm-pg0.wisc.cloudlab.us"
fi

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

tarFile="SWIM"; testCase="../SWIM"; rm -rf .$testCase/*.class; uploadTestCases $tarFile $testCase &

tarFile="spark-test-cases"; testCase="../spark-test-cases"; uploadTestCases $tarFile $testCase &

#tarFile="wordcount"; testCase="../flink-test-cases/wordcount"; uploadTestCases $tarFile $testCase &

wait

