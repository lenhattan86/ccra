# download a text of a book
#wget -O bigfile.txt http://www.gutenberg.org/files/52185/52185-0.txt
if [ -f book.t ]
then
	echo 'file exists'
else
	echo 'file does not exist'
	wget -O book.t http://www.textfiles.com/etext/NONFICTION/bacon-essays-92.txt
fi

cp book.t bigfile.txt
# 14 -> 5.1GB = fileszie * (2^14)
# 13 -> 19M
# 12 -> 38
# 11 -> 19M
# 2 -> 

if [ -z "$1" ]
then
	duplicate=12
else
	duplicate=$1
fi

for i in {1..11}; do cat bigfile.txt bigfile.txt > temp.txt && mv temp.txt bigfile.txt; done

sudo rm -rf temp.txt 
