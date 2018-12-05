defaulHostname="ctl.bpf2.yarnrm-pg0.utah.cloudlab.us"
defaultFolder="edf"
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

resultPath="../results/debug"

method=""
echo "[INFO] download the files from $hostname"

if [ -z "$2" ]
then
	newFolder=$defaultFolder
else
	newFolder="$2"
fi

subfolder1="users/tanle/SWIM/scriptsTest/workGenLogs"
subfolder2="users/tanle/SWIM/scriptsTest"

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
	rm -rf $resultPath/$hostname/$3;
	mkdir $resultPath/$hostname/
	ssh tanle@$hostname "tar zcvf $1.tar $2"
	mkdir $resultPath/$hostname/$3	
	scp $hostname:~/$1.tar $resultPath/$hostname/$3 
	tar -xvzf $resultPath/$hostname/$3/$1.tar -C $resultPath/$hostname/$3
	ssh tanle@$hostname "rm -rf $1.tar"
	rm -rf $resultPath/$3/$1.tar;
	rm -rf $resultPath/$hostname/$3/$subfolder1/*.txt
	rm -rf $resultPath/$hostname/$3/$subfolder2/*.sh
	scp $hostname:/users/tanle/SWIM/workGenLogs/yarnUsedResources.csv $resultPath/$hostname/$3/$subfolder1/
}

#prompt


tarFile="scriptTest"; folder="~/SWIM/scriptsTest"; 
ssh tanle@$hostname "rm -rf ~/SWIM/scriptsTest/workGenLogs/completion_time.csv; hadoop/bin/hadoop fs -copyToLocal /user/tanle/completion_time.csv ~/SWIM/scriptsTest/workGenLogs/completion_time.csv;"
ssh tanle@$hostname "rm -rf ~/SWIM/scriptsTest/workGenLogs/tez_container_time.csv; hadoop/bin/hadoop fs -copyToLocal /user/tanle/tez_container_time.csv ~/SWIM/scriptsTest/workGenLogs/tez_container_time.csv;"
downloadOuput $tarFile $folder $newFolder
#ssh tanle@$hostname "hadoop/bin/hadoop fs -rm -skipTrash /user/tanle/completion_time.csv;"

#tarFile="logs"; folder="~/hadoop/logs"; logFolder="logs"; downloadOuput $tarFile $folder $logFolder
#tarFile="SWIM"; srcFolder="~/SWIM"; destFolder="SWIM"; downloadOuput $tarFile $srcFolder $destFolder

echo "[INFO] $hostname "
echo "[INFO] Finished at: $(date) "
