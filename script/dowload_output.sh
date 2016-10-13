#hostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"; method="perf"
hostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"; method="drf"
#hostname="c220g1-030826.wisc.cloudlab.us" #drf

resultPath="../results"
echo "download the files from $hostname"

downloadOuput () {
	echo "download $2 ................"
	ssh tanle@$hostname "tar zcvf $1.tar $2"	
	scp $hostname:~/$1.tar $resultPath/$method 
	tar -xvzf $resultPath/$method/$1.tar
	ssh tanle@$hostname "rm -rf $1.tar"
	rm -rf $resultPath/$method/$1.tar;
}

tarFile="scriptTest"; folder="~/SWIM/scriptsTest"; downloadOuput $tarFile $folder

