#!/bin/bash
OLD_IFS="$IFS"
IFS=" "
while read line
do
  arr=($line)
	method=${arr[0]}
  api=${arr[1]}
  content=${arr[2]}
	if [ "$method" != "#" ]; then
    echo "method=$method"
    echo "api=$api"
    echo "content=$content"
	  ~/tsung_jmeter.sh -m $method -a $api -c $content
	fi
done < $1

IFS="$OLD_IFS"