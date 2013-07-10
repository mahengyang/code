#!/bin/bash
jmeterHome="/usr/local/bin/apache-jmeter-2.9"
jmeter="$jmeterHome/bin/jmeter"
stopTest="$jmeterHome/bin/stoptest.sh"
CMDRunner="$jmeterHome/lib/ext/CMDRunner.jar"
reportPath="$HOME/jmeterReport"
#AggregateReport = JMeter's native Aggregate Report, can be saved only as CSV
#ThreadsStateOverTime = Active Threads Over Time
#PerfMon = PerfMon Metrics Collector
#TimesVsThreads = Response Times VS Threads
reports="AggregateReport ThreadsStateOverTime BytesThroughputOverTime HitsPerSecond LatenciesOverTime ResponseCodesPerSecond ResponseTimesDistribution ResponseTimesOverTime ResponseTimesPercentiles ThroughputOverTime ThroughputVsThreads TimesVsThreads TransactionsPerSecond PageDataExtractorOverTime"
while getopts "t:j:h" arg 
do
  case $arg in
   t)
      tsungFile="$OPTARG"
      ;;
   j)
      jmeterFile="$OPTARG" 
      ;;
   h)
      echo "-t:tsung test file(.xml)"
      echo "-j:jmeter test file(.jmx)"
      ;;
     ?)
    echo "you have wrong input,please use -h see how to use"
  exit 1
  ;;
  esac
done
if [ ! -n "$jmeterFile" ] || [ ! -n "$tsungFile" ]; then
  echo "use -h see help"
  exit 0
fi

jmeterLog="/tmp/jmeter.log"
jmeterJtl="/tmp/jmeter.jtl"
rm $jmeterLog > /dev/null 2>&1
rm $jmeterJtl > /dev/null 2>&1

$jmeter -n -t $jmeterFile -l $jmeterLog &
echo "jmeter start"

tsung -f $tsungFile start &
echo "tsung start"

if [ ! -d $reportPath ]; then 
  mkdir $reportPath 
fi 

wait %2
`$stopTest`
wait %1
#generate report
for report in $reports 
 do
    echo "create report: $report"
    java -jar $CMDRunner --tool Reporter --generate-png "$reportPath/$report.png" --input-jtl $jmeterLog --plugin-type $report --width 2000 --height 700 > /dev/null 2>&1 &
 done
java -jar $CMDRunner --tool Reporter --generate-png "$reportPath/PerfMon.png" --input-jtl $jmeterJtl --plugin-type PerfMon --width 2500 --height 700 > /dev/null 2>&1 &
java -jar $CMDRunner --tool Reporter --generate-csv "$reportPath/PerfMon.csv" --input-jtl $jmeterJtl --plugin-type PerfMon > /dev/null 2>&1 &

