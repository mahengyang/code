#!/bin/bash
desdir="/home/deployer/.tsung/log" 
echo "<html><body><h1>welcom to tsung test report</h1>"
for dirlist in $(ls $desdir)
do
  if [ -f "$desdir/$dirlist/test.env" ] ; then
    testenv=`cat "$desdir/$dirlist/test.env" | grep -E "method:|user:|loop:|duration:|thinktime:|maxuser:"`
    api=`cat "$desdir/$dirlist/test.env" | grep api:`
    #api contains ?
    api=${api%%\?*}
    echo "<a href=\"log/$dirlist\">$dirlist -- $api -- `echo $testenv | xargs`</a>"
    echo "<br>"
    echo "<img src=\"log/$dirlist/images/graphes-HTTP_CODE-rate_tn.png\" alt=\"http_code_rate\" />"
    echo "<img src=\"log/$dirlist/images/graphes-Perfs-mean_tn.png\" alt=\"perfs-meann\" />"
    echo "<br>"
  fi
done
echo "</body></html>"
