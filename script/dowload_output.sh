hostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"; method="perf"
#hostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"; method="drf"
#hostname="c220g1-030826.wisc.cloudlab.us" #drf

resultPath="../results"
newFolder="/test"
echo "download the files from $hostname"

downloadOuput () {
	echo "download $2 ................"
	ssh tanle@$hostname "tar zcvf $1.tar $2"
	mkdir $resultPath/$method$newFolder	
	scp $hostname:~/$1.tar $resultPath/$method$newFolder 
	tar -xvzf $resultPath/$method$newFolder/$1.tar -C $resultPath/$method$newFolder
	ssh tanle@$hostname "rm -rf $1.tar"
	#rm -rf $resultPath/$method$newFolder/$1.tar;
}

tarFile="scriptTest"; folder="~/SWIM/scriptsTest"; downloadOuput $tarFile $folder

