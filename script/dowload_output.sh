defaulHostname="nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us"
#defaulHostname="c220g1-030826.wisc.cloudlab.us" #drf

if [ -z "$1" ]
then
	hostname=$defaulHostname
else
	hostname="nm.$1.yarnrm-pg0.wisc.cloudlab.us"
fi

resultPath="../results"
newFolder="/runb2i1"
echo "download the files from $hostname"

downloadOuput () {
	echo "download $2 ................"
	rm -rf $resultPath/$hostname/$newFolder;
	mkdir $resultPath/$hostname/
	ssh tanle@$hostname "tar zcvf $1.tar $2"
	mkdir $resultPath/$hostname/$newFolder	
	scp $hostname:~/$1.tar $resultPath/$hostname$newFolder 
	tar -xvzf $resultPath/$hostname/$newFolder/$1.tar -C $resultPath/$hostname$newFolder
	ssh tanle@$hostname "rm -rf $1.tar"
	rm -rf $resultPath/$method$newFolder/$1.tar;
}

tarFile="scriptTest"; folder="~/SWIM/scriptsTest"; downloadOuput $tarFile $folder

