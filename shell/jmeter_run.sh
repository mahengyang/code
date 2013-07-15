#!/bin/bash
#default parameters
defaultTestFile="$HOME/jmeter_test.jmx"
defaultUser=3000
#s
defaultRamptime=100
#ms
defaultThinktime=10000
defaultServer="LDKJSERVER0007"
defaultPort=9002
defaultApi="/v2/locations/checkin"
defaultMethod="POST"
#1+port
defaultJmxPort="1$defaultPort"
defaultLoopCount=50

while [ $# -gt 0 ]; do
  case "$1" in
    -j|--testFile)
            testFile=$2
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
    -m|--method)
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
            echo "-f | --testFile : jmeter test file jmx,default $defaultTestFile"
            echo "-u | --user: total user number,default $defaultUser"
            echo "-r | --ramptime: times used to generate user,default $defaultRamptime s"
            echo "-t | --thinktime: the inteval time between two request,default $defaultThinktime ms"
            echo "-l | --loopCount: Each user's request number,default $defaultLoopCount"
            echo "-s | --server: play server,default $defaultServer"
            echo "-p | --port: play server http port,default $defaultPort"
            echo "-a | --api: api, default $defaultApi"
            echo "-m | --method: POST/GET,default $defaultMethod"
            echo "-x | --jmxPort: jmxPort used in play server,to monitor gc time,default $defaultJmxPort"
            echo "-h | --help: print this help"
            shift
            exit 1
            ;;
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
processName="jmeter"
pid=`ps aux | grep $processName | grep -v grep | awk '{print $2}'`
#convert from string to array
pid=($pid)
if [ ${#pid[*]} -gt 3 ]; then
  echo "warning!!! a jmeter process is running,please wait"
  exit 1
fi

#env
jmeterHome="/usr/local/bin/apache-jmeter-2.9"
jmeter="$jmeterHome/bin/jmeter"
stopTest="$jmeterHome/bin/stoptest.sh"
CMDRunner="$jmeterHome/lib/ext/CMDRunner.jar"

currentTest=`date +%Y%m%d-%H%M`
reportPath="$HOME/jmeterReport/$currentTest"
mkdir -p $reportPath
jmeterLog="$reportPath/request.jtl"
jmeterJtl="$reportPath/PerfMon.jtl"

#set default parameters
testFile=${testFile:=$defaultTestFile}
user=${user:=$defaultUser}
ramptime=${ramptime:=$defaultRamptime}
thinktime=${thinktime:=$defaultThinktime}
server=${server:=$defaultServer}
port=${port:=$defaultPort}
api=${api:=$defaultApi}
method=${method:=$defaultMethod}
jmxPort=${jmxPort:=$defaultJmxPort}
loopCount=${loopCount:=$defaultLoopCount}

#key of paramJmeter is nodname in jmeter_test.jmx file
declare -A paramJmeter
paramJmeter=( \
  ["totalUser"]=$user \
  ["totalTime"]=$ramptime \
  ["thinktime"]=$thinktime \
  ["server"]=$server \
  ["port"]=$port \
  ["api"]=$api \
  ["method"]=$method \
  ["jtlFile"]=$jmeterJtl \
  ["jmxPort"]=$jmxPort \
  ["loopCount"]=$loopCount \
  )

#deal with jmx file
cp $testFile $reportPath
currentTestFile="$reportPath/jmeter_test.jmx"
function replace(){
  echo "$1:$2" | tee -a "$reportPath/test.env"
  #change / to \/ for sed 
  local val=${2//\//\\\/}
  sed -i "s/@${1}/${val}/" $currentTestFile
}
for key in ${!paramJmeter[*]}
do
  replace $key ${paramJmeter[$key]}
done
#start jmeter
$jmeter -n -t $currentTestFile -l $jmeterLog &

wait %1

echo "create report: PerfMon"
java -jar $CMDRunner --tool Reporter --generate-png "$reportPath/PerfMon.png" --input-jtl $jmeterJtl --plugin-type PerfMon --width 3200 --height 700 > /dev/null 2>&1
java -jar $CMDRunner --tool Reporter --generate-csv "$reportPath/PerfMon.csv" --input-jtl $jmeterJtl --plugin-type PerfMon > /dev/null 2>&1
