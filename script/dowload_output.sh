defaulHostname="ctl.bpf2.yarnrm-pg0.utah.cloudlab.us"
# defaultFolder="drf"
defaultFolder="bopf2"
# defaulHostname="ctl.bpf.yarnrm-pg0.utah.cloudlab.us"
# defaultFolder="bopf"
#defaulHostname="ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us"

#defaultDomain="yarnrm-pg0.utah.cloudlab.us"
defaultDomain="yarnrm-pg0.clemson.cloudlab.us"

if [ -z "$1" ]
then
	hostname=$defaulHostname
else
	hostname="ctl.$1.$defaultDomain"
fi

resultPath="../results/debug/motivation"
# resultPath="$resultPath/$hostname"
method=""
echo "[INFO] download the files from $hostname"

if [ -z "$2" ]
then
	newFolder=$defaultFolder
else
	newFolder="$2"
fi

# subfolder1="users/tanle/SWIM/scriptsTest/workGenLogs"
# subfolder2="users/tanle/SWIM/scriptsTest"
subfolder1="/users/tanle/result"
subfolder2="/users/tanle/result"

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
	echo "[INFO] download $2 ................"
	rm -rf $resultPath/$3;
	mkdir $resultPath/
	ssh tanle@$hostname "tar zcvf $1.tar $2"
	mkdir $resultPath/$3	
	scp $hostname:~/$1.tar $resultPath/$3 
	tar -xvzf $resultPath/$3/$1.tar -C $resultPath/$3
	ssh tanle@$hostname "rm -rf $1.tar"
	rm -rf $resultPath/$3/$1.tar;
	rm -rf $resultPath/$3/$subfolder1/*.txt
	rm -rf $resultPath/$3/$subfolder2/*.sh
	# scp $hostname:$subfolder2/yarnUsedResources.csv $resultPath/$3/$subfolder1/
}

#prompt


tarFile="result"; folder="~/result"; 
downloadOuput $tarFile $folder $newFolder

echo "[INFO] $hostname "
echo "[INFO] Finished at: $(date) "
