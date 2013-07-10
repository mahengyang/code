#!/bin/bash
while [ $# -gt 0 ]; do
  case "$1" in
    -j|--jmeterFile)
            jmeterFile=$2
            shift 
            shift ;;
    -u|--user)
            user=$2
            shift 
            shift ;;
    -r|--ramptime)
            ramptime=$2
            shift 
            shift ;;
    -t|--thinktime)
            thinktime=$2
            shift 
            shift ;;
    -s|--server)
            server=$2
            shift 
            shift ;;
    -p|--port)
            port=$2
            shift 
            shift ;;
    -a|--api)
            api=$2
            shift 
            shift ;;
    -s|--method)
            method=$2
            shift 
            shift ;;
    -x|--jmxPort)
            jmxPort=$2
            shift 
            shift ;;
    -l|--loopCount)
            loopCount=$2
            shift 
            shift ;;
    -h|--help)
            echo "-j | --jmeterFile : jmeter test file jmx"
            echo "-u | --user: total user number"
            echo "-r | --ramptime: times used to generate user"
            echo "-t | --thinktime: the inteval time between two request"
            shift ;;
    --)
      shift
      break
      ;;
    *)
      echo "wrong input:$1,use -h or --help see how to use" 1>&2
      exit 1
      ;;
  esac
done

#env
jmeterHome="/usr/local/bin/apache-jmeter-2.9"
jmeter="$jmeterHome/bin/jmeter"
stopTest="$jmeterHome/bin/stoptest.sh"
CMDRunner="$jmeterHome/lib/ext/CMDRunner.jar"

currentTest=`date +%Y%m%d%H%M%S`
reportPath="$HOME/jmeterReport/$currentTest"
mkdir -p $reportPath
jmeterLog="$reportPath/request.jtl"
jmeterJtl="$reportPath/PerfMon.jtl"

#set default parameters
jmeterFile=${jmeterFile:="$HOME/jmeter_test.jmx"}
user=${user:="3000"}
ramptime=${ramptime:="100"}
thinktime=${thinktime:="10"}
server=${server:="LDKJSERVER0007"}
port=${port:="9002"}
api=${api:="/v2/locations/checkin"}
method=${method:="POST"}
jmxPort=${jmxPort:="19002"}
loopCount=${loopCount:="50"}

#key of paramJmeter is nodname in jmeter_test.jmx file
declare -A paramJmeter
paramJmeter=( \
  ["totalUser"]=$user \
  ["totalTime"]=$ramptime \
  ["thinktime"]=$thinktime \
  ["server"]=$server \
  ["httpPort"]=$port \
  ["httpPath"]=$api \
  ["httpMethod"]=$method \
  ["jtlFile"]=$jmeterJtl \
  ["jmxPort"]=$jmxPort \
  ["loopCount"]=$loopCount \
  )

#deal with jmx file
cp $jmeterFile $reportPath
currentJmeterFile="$reportPath/jmeter_test.jmx"
function replace(){
  echo $1,$2
  #change / to \/ for sed 
  local val=${2//\//\\\/}
  sed -i "s/${1}/${val}/" $currentJmeterFile
}
for key in ${!paramJmeter[*]}
do
  replace $key ${paramJmeter[$key]}
done
#start jmeter
#$jmeter -n -t $currentJmeterFile -l $jmeterLog &
#
#wait %1
#
#reports="AggregateReport ThreadsStateOverTime BytesThroughputOverTime HitsPerSecond LatenciesOverTime ResponseCodesPerSecond ResponseTimesDistribution ResponseTimesOverTime ResponseTimesPercentiles ThroughputOverTime ThroughputVsThreads TimesVsThreads TransactionsPerSecond PageDataExtractorOverTime"
##generate report
#for report in $reports 
#do
#   echo "create report: $report"
#   java -jar $CMDRunner --tool Reporter --generate-png "$reportPath/$report.png" --input-jtl $jmeterLog --plugin-type $report --width 1200 --height 700 > /dev/null 2>&1
#done
#echo "create report: PerfMon"
#java -jar $CMDRunner --tool Reporter --generate-png "$reportPath/PerfMon.png" --input-jtl $jmeterJtl --plugin-type PerfMon --width 3200 --height 700 > /dev/null 2>&1
#java -jar $CMDRunner --tool Reporter --generate-csv "$reportPath/PerfMon.csv" --input-jtl $jmeterJtl --plugin-type PerfMon > /dev/null 2>&1
