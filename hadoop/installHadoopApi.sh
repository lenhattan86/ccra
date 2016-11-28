version="2.7.2.1"



#jarFiles=("ns1.nixcraft.net." "ns2.nixcraft.net." "ns3.nixcraft.net.")
jarFiles=("hadoop-annotations-$version"
"hadoop-ant-$version"
"hadoop-archives-$version"
"hadoop-assemblies-$version"
"hadoop-auth-$version"
"hadoop-aws-$version"
"hadoop-azure-$version"
"hadoop-client-$version"
"hadoop-common-$version"
"hadoop-common-$version-tests"
#"hadoop-core"
"hadoop-datajoin-$version"
"hadoop-distcp-$version"
"hadoop-extras-$version"
"hadoop-gridmix-$version"
"hadoop-hdfs-$version"
"hadoop-hdfs-$version-tests"
"hadoop-kms-$version"
"" #"hadoop-main"
"hadoop-mapreduce-client-app-$version"
"hadoop-mapreduce-client-common-$version"
"hadoop-mapreduce-client-core-$version"
"hadoop-mapreduce-client-hs-$version"
"hadoop-mapreduce-client-jobclient-$version"
"hadoop-mapreduce-client-jobclient-$version-tests"
"hadoop-mapreduce-client-shuffle-$version"
"" #"hadoop-mapreduce-client"
"hadoop-maven-plugins-$version" #"hadoop-maven-plugins"
"hadoop-minicluster-$version"
"hadoop-minikdc-$version"
"hadoop-nfs-$version"
"hadoop-openstack-$version"
"" #hadoop-project-dist-$version
"" #"hadoop-project"
"hadoop-rumen-$version"
"hadoop-sls-$version"
"hadoop-streaming-$version"
#"hadoop-test"
"" #"hadoop-tools"
"hadoop-yarn-api-$version"
"hadoop-yarn-client-$version"
"hadoop-yarn-common-$version"
"hadoop-yarn-common-$version-tests"
"hadoop-yarn-server-applicationhistoryservice-$version"
"hadoop-yarn-server-common-$version"
"hadoop-yarn-server-nodemanager-$version"
"hadoop-yarn-server-resourcemanager-$version"
"hadoop-yarn-server-tests-$version"
"hadoop-yarn-server-tests-$version-tests"
"hadoop-yarn-server-web-proxy-$version"
"" #"hadoop-yarn-server"
"" #"hadoop-yarn"
)

jarFolders=("hadoop-common-project/hadoop-annotations"
"hadoop-tools/hadoop-ant"
"hadoop-tools/hadoop-archives"
"hadoop-assemblies"
"hadoop-common-project/hadoop-auth"
"hadoop-tools/hadoop-aws"
"hadoop-tools/hadoop-azure"
"hadoop-client"
"hadoop-common-project/hadoop-common"
"hadoop-common-project/hadoop-common"
#"hadoop-core" hadoop-common-project/hadoop-common/target/hadoop-common-2.7.2.1/share/hadoop/common/jdiff
"hadoop-tools/hadoop-datajoin"
"hadoop-tools/hadoop-distcp"
"hadoop-tools/hadoop-extras"
"hadoop-tools/hadoop-gridmix"
"hadoop-hdfs-project/hadoop-hdfs"
"hadoop-hdfs-project/hadoop-hdfs"
"hadoop-common-project/hadoop-kms"
"./" #"hadoop-main"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-app"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-common"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-core"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-hs"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient"
"hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-shuffle"
"hadoop-mapreduce-project/hadoop-mapreduce-client" #"hadoop-mapreduce-client"
"hadoop-maven-plugins" #"hadoop-maven-plugins"
"hadoop-minicluster"
"hadoop-common-project/hadoop-minikdc"
"hadoop-common-project/hadoop-nfs"
"hadoop-tools/hadoop-openstack"
"hadoop-project-dist"
"hadoop-project" 
"hadoop-tools/hadoop-rumen"
"hadoop-tools/hadoop-sls"
"hadoop-tools/hadoop-streaming"
#"hadoop-test"
"hadoop-tools"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-api"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-client"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-common"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-common"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-applicationhistoryservice"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-common"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-resourcemanager"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-tests"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-tests"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-web-proxy"
"hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server"
"hadoop-yarn-project/hadoop-yarn"
)

jarFiles=("hadoop-common-$version-tests")
jarFolders=("hadoop-common-project/hadoop-common")

# get length of an array
numOfJars=${#jarFiles[@]}
 
pids=""
# use for loop read all nameservers
for (( i=0; i<${numOfJars}; i++ ));
do
	if [ "${jarFiles[$i]}" == "" ]; then
		#mvn install:install-file -Dfile=${jarFolders[$i]}/pom.xml -Dpackaging=pom -DpomFile=${jarFolders[$i]}/pom.xml & pids="$pids $!"
		echo "POM ${jarFolders[$i]}/pom.xml"
		mvn org.apache.maven.plugins:maven-install-plugin:2.5.1:install-file -Dfile=${jarFolders[$i]}/pom.xml -Dpackaging=pom -DpomFile=${jarFolders[$i]}/pom.xml -DlocalRepositoryPath=/home/tanle/myRepo -DcreateChecksum=true & pids="$pids $!"
	else
		echo "Jar ${jarFolders[$i]}/target/${jarFiles[$i]}.jar + POM ${jarFolders[$i]}/pom.xml"
		#mvn install:install-file -Dfile=${jarFolders[$i]}/target/${jarFiles[$i]}-$version.jar -DpomFile=${jarFolders[$i]}/pom.xml & pids="$pids $!" 
		mvn install:install-file -Dfile=${jarFolders[$i]}/target/${jarFiles[$i]}.jar -DlocalRepositoryPath=/home/tanle/myRepo -DcreateChecksum=true -DgroupId=org.apache.hadoop -DartifactId=hadoop-common -Dpackaging=jar -Dversion=$version & pids="$pids $!"
		#mvn org.apache.maven.plugins:maven-install-plugin:2.5.1:install-file -Dfile=${jarFolders[$i]}/target/${jarFiles[$i]}.jar -DpomFile=${jarFolders[$i]}/pom.xml -DlocalRepositoryPath=/home/tanle/myRepo -DcreateChecksum=true & pids="$pids $!" 
	fi
	
done 
wait $pids

#mvn install -DlocalRepositoryPath=/home/tanle/myRepo -DcreateChecksum=true



