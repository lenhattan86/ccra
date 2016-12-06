defaulHostname="ctl.yarn-perf.yarnrm-pg0.wisc.cloudlab.us"

if [ -z "$1" ]
then
	hostname=$defaulHostname
else
	hostname="ctl.$1.yarnrm-pg0.wisc.cloudlab.us"
fi

resultPath="../results"
newFolder="runb3i1"
method=""
echo "download the files from $hostname"

prompt () {
	while true; do
	    read -p "Do you wish to overwrite $hostname $newFolder? " yn
	    case $yn in
		[Yy]* ) make install; break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
	    esac
	done
}


downloadOuput () {
	echo "download $2 ................"
	rm -rf $resultPath/$hostname/$newFolder;
	mkdir $resultPath/$hostname/
	ssh tanle@$hostname "tar zcvf $1.tar $2"
	mkdir $resultPath/$hostname/$newFolder	
	scp $hostname:~/$1.tar $resultPath/$hostname/$newFolder 
	tar -xvzf $resultPath/$hostname/$newFolder/$1.tar -C $resultPath/$hostname/$newFolder
	ssh tanle@$hostname "rm -rf $1.tar"
	rm -rf $resultPath/$method$newFolder/$1.tar;
}

#prompt

tarFile="scriptTest"; folder="~/SWIM/scriptsTest"; downloadOuput $tarFile $folder

#tarFile="logs"; folder="~/hadoop/logs"; downloadOuput $tarFile $folder

