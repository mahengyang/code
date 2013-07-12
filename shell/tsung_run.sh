#!/bin/bash
defaultTestFile="$HOME/tsung_test.xml"
defaultUser=20
defaultDuration=100
# s
defaultThinktime=1
defaultServer="LDKJSERVER0007"
defaultPort=9002
defaultApi="/v2/locations/checkin"
defaultMethod="POST"
defaultLoopCount=50
defaultMaxuser=5000

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--testFile)
            testFile=$2
            shift 
            shift ;;
    -u|--user)
            user=$2
            shift 
            shift ;;
    -d|--duration)
            duration=$2
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
    -l|--loopCount)
            loopCount=$2
            shift 
            shift ;;
    -x|--maxuser)
            maxuser=$2
            shift 
            shift ;;
    -h|--help)
            echo "-f | --testFile: tsung test file xml,default $defaultTestFile"
            echo "-u | --user: user number per second, default $defaultUser"
            echo "-x | --maxuser: max user number, default $defaultMaxuser"
            echo "-d | --duration: times used to generate user,default $defaultDuration s"
            echo "-t | --thinktime: the inteval time between two request,default $defaultThinktime s"
            echo "-l | --loopCount: Each user's request number,default $defaultLoopCount"
            echo "-s | --server: play server,default $defaultServer"
            echo "-p | --port: play server http port,default $defaultPort"
            echo "-a | --api: api, default $defaultApi"
            echo "-m | --method: POST/GET,default $defaultMethod"
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

processName="tsung"
pid=`ps aux | grep $processName | grep -v grep | awk '{print $2}'`
#convert from string to array
pid=($pid)
if [ ${#pid[*]} -gt 3 ]; then
  echo "warning!!! a $processName process is running,please wait"
  exit 1
fi

#env
#set default parameters
testFile=${testFile:=$defaultTestFile}
user=${user:=$defaultUser}
duration=${duration:=$defaultDuration}
thinktime=${thinktime:=$defaultThinktime}
server=${server:=$defaultServer}
port=${port:=$defaultPort}
api=${api:=$defaultApi}
method=${method:=$defaultMethod}
loopCount=${loopCount:=$defaultLoopCount}
maxuser=${maxuser:=$defaultMaxuser}

#key of params is nodname in tusng_test.xml file
declare -A params
params=( \
  ["user"]=$user \
  ["maxuser"]=$maxuser \
  ["duration"]=$duration \
  ["thinktime"]=$thinktime \
  ["server"]=$server \
  ["port"]=$port \
  ["api"]=$api \
  ["method"]=$method \
  ["loopCount"]=$loopCount \
  )
reportPath="$HOME/.tsung/log"
currentTest=`date +%Y%m%d-%H%M`
reportPath="$reportPath/$currentTest"
mkdir -p $reportPath
#deal with jmx file
cp $testFile $reportPath
currentTestFile="$reportPath/tsung_test.xml"
function replace(){
  echo "$1:$2" | tee -a "$reportPath/test.env"
  #change / to \/ for sed 
  local val=${2//\//\\\/}
  sed -i "s/@${1}/${val}/" $currentTestFile
}
for key in ${!params[*]}
do
  replace $key ${params[$key]}
done
#start tsung 
tsung -f $currentTestFile start &
wait %1
cd $reportPath
/usr/local/lib/tsung/bin/tsung_stats.pl
