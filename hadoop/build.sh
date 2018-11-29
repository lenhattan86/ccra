mvn eclipse:eclipse & 
mvn package -Pdist -DskipTests -Dtar
echo $(date '+%d/%m/%Y %H:%M:%S')