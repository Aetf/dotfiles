#!/bin/bash

#set -x

scode="gbk"
dcode="utf-8"

function Usage()
{
	cat << EOF
Usage: conv [OPTIONS] [DIR]
[-u]	GBK to UTF-8
[-g]	UTF-8 to GBK
EOF
	exit 1
}


#将当前目录下所有普通文件进行转码 GBK to UTF-8
function g2u()
{
	local dir=$1
	printf "Entering $dir ...\n"
	for file in $(ls $dir)
	do
		file="$dir/$file"
		if [ -f $file ];then

			#进行转码
			printf "\tConverting $file ...\n"

			local tmpfile=$(mktemp)
			Fright=$(stat -c %a $file)
			Fuser=$(stat -c %U $file)
			Fgro=$(stat -c %G $file)
			iconv -f $scode -t $dcode $file > $tmpfile || Usage
			mv $tmpfile $file &&
			chmod $Fright $file
			chown $Fuser:$Fgrp $file

			dos2unix $file
		fi
	done
	printf "Leaving $dir\n"
}

function u2g()
{
	local dir=$1
	printf "Entering $dir ...\n"
	for file in $(ls $dir)
	do
		file="$dir/$file"
		if [ -f $file ];then

			#进行转码
			printf "\tConverting $file ...\n"
			local tmpfile=$(mktemp)
			Fright=$(stat -c %a $file)
			Fuser=$(stat -c %U $file)
			Fgro=$(stat -c %G $file)
			iconv -f $dcode -t $scode $file > $tmpfile || Usage
			mv $tmpfile $file &&
			chmod $Fright $file
			chown $Fuser:$Fgrp $file

			unix2dos $file
		fi
	done
	printf "Leaving $dir\n"
}

[ $# -ne 2 ] && Usage

while getopts ug opt
do
	case $opt in
		u) echo "Convert gbk coding to utf-8 ...."
		for dir in $(find $2 -type d)
		do
			g2u $dir
		done
		;;
		g) echo "Convert utf-8 coding to gbk ...."
		for dir in $(find $2 -type d)
		do
			u2g $dir
		done
		;;
		*) Usage
		exit 1
		;;
	esac
done

exit 0
