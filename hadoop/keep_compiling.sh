while true
do
	clear
	echo "                       "
	echo "==========================================="
	date --rfc-3339=seconds
	echo "Compiling...."
	mvn package -Pdist -DskipTests -Dtar
	echo "Done at"
	date --rfc-3339=seconds
	echo "You can deploy now ..."
	echo "==========================================="
	echo "                       "
	sleep 30
done
