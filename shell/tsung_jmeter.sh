#!/bin/bash
jmeterRun="./jmeter_run.sh"
tsungRun="./tsung_run.sh"

$jmeterRun -s LDKJSERVER0006 -p 9016 -u 1 -r 1 -t 10000000 -l 2 &

$tsungRun -u 40 -d 500 -x 10000 -l 5 -s LDKJSERVER0006 -p 9016 -a /v2/stest5 -m GET &

wait %2 
#stop jmeter when tsung is complete
/usr/local/bin/apache-jmeter-2.9/bin/stoptest.sh
