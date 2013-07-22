#!/bin/bash
desdir="/tmp" 
count=`ls $desdir | wc -l`
for dirlist in $(ls $desdir)
do
count=`ls "$desdir/$dirlist" | wc -l`
  if [ "$count" -le 4 ] ; then
    echo "to be delete $desdir/$dirlist"
    `rm -rf "$desdir/$dirlist"`
  fi
done
