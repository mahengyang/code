#!/bin/bash
jmeterRun="./jmeter_run.sh"
jmeterReportPath="$HOME/jmeterReport"

defaultTestFile="$HOME/tsung_test.xml"
defaultUser=20
defaultDuration=100
# s
defaultThinktime=1
defaultServer="LDKJSERVER0007"
defaultPort=9002
defaultApi="/v2/locations/checkin"
defaultMethod="POST"
defaultloop=50
defaultMaxuser=5000
defaultProbabilityGet=0
defaultContents='{&quot;u&quot;:&quot;a&quot;,&quot;mcc&quot;:460,&quot;n&quot;:&quot;a&quot;,&quot;by&quot;:0,&quot;mnc&quot;:1,&quot;lnt&quot;:116.345031,&quot;cid&quot;:4936921,&quot;lat&quot;:39.980952,&quot;lac&quot;:41019,&quot;dId&quot;:&quot;35513605339286910683F9028B1&quot;,&quot;x&quot;:&quot;3352--10683F9028B1-4075689767927285040&quot;}'

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
    -l|--loop)
            loop=$2
            shift 
            shift ;;
    -x|--maxuser)
            maxuser=$2
            shift 
            shift ;;
    -c|--contents)
			contents=$2
			shift
			shift ;;
    -h|--help)
            echo "-f | --testFile: tsung test file xml,default $defaultTestFile"
            echo "-u | --user: user number per second, default $defaultUser"
            echo "-x | --maxuser: max user number, default $defaultMaxuser"
            echo "-d | --duration: times used to generate user,default $defaultDuration s"
            echo "-t | --thinktime: the inteval time between two request,default $defaultThinktime s"
            echo "-l | --loop: Each user's request number,default $defaultloop"
            echo "-s | --server: play server,default $defaultServer"
            echo "-p | --port: play server http port,default $defaultPort"
            echo "-a | --api: api, default $defaultApi"
            echo "-m | --method: POST/GET,default $defaultMethod"
            echo "-c | --contents: POST request body"
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
loop=${loop:=$defaultloop}
maxuser=${maxuser:=$defaultMaxuser}
contents=${contents:=$defaultContents}
#ignore lower and upper, warning ! [[ ]]
if [[ $method = [Gg][Ee][Tt] ]]; then
	probabilityGet=100
fi
probabilityGet=${probabilityGet:=$defaultProbabilityGet}
probabilityPOST=`expr 100 - $probabilityGet`

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
  ["loop"]=$loop \
  ["contents"]=$contents \
  ["probabilityGet"]=$probabilityGet \
  ["probabilityPOST"]=$probabilityPOST
  )
reportPath="$HOME/.tsung/log"
currentTest=`date +%Y%m%d-%H%M`
reportPath="$reportPath/$currentTest"
echo "make tsung report path $reportPath"
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

#start jmeter 
$jmeterRun -s $server -p $port -u 1 -r 1 -t 100000000 -l 2 -x "1$port" &
#start tsung 
tsung -f $currentTestFile start &

wait %2
cd $reportPath
/usr/local/lib/tsung/bin/tsung_stats.pl

#stop jmeter when tsung is complete
/usr/local/bin/apache-jmeter-2.9/bin/stoptest.sh
wait %1

cp "$jmeterReportPath/$currentTest/PerfMon.png" "$reportPath"
cp "$jmeterReportPath/$currentTest/PerfMon.csv" "$reportPath"