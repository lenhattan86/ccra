sudo rm -rf /dev/cpubound1.txt
# download a text of a book
#wget -O book01.t http://www.gutenberg.org/files/52185/52185-0.txt
#wget -O book01.t http://www.textfiles.com/etext/NONFICTION/bacon-essays-92.txt
sudo cp book01.t /dev/cpubound1.txt
# 14 -> 5.1GB = fileszie * (2^14)
# 13 -> 19M
# 12 -> 38
# 11 -> 19M
# 2 -> 
for i in {1..5}; do sudo cat /dev/cpubound1.txt /dev/cpubound1.txt > temp1.txt && sudo mv temp1.txt /dev/cpubound1.txt; done

~/hadoop-2.7.0/bin/hadoop fs -mkdir hdfs:///cpubound

~/hadoop-2.7.0/bin/hadoop fs -rmr -skipTrash hdfs:///cpubound/cpubound1.txt

~/hadoop-2.7.0/bin/hadoop fs -rmr -skipTrash hdfs:///cpubound/cpubound1.out

~/hadoop-2.7.0/bin/hadoop fs -copyFromLocal -f /dev/cpubound1.txt hdfs:///cpubound/cpubound1.txt

$HOME/flink-1.0.3/bin/flink run -c cpubound.IterateExample -m yarn-cluster -yn 7 -yq -yst -yqu root.sls_queue_3 $HOME/flink-run/flink-target/cpu-bound-0.1.jar --output  hdfs:///cpubound/cpu-bound.out
