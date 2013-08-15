#!/bin/bash
#################env
jmeterRun="./jmeter_run.sh"
scriptPath="/usr/local/apps/DmCloud/shared/scripts"
tsung_log_path="$HOME/.tsung/log"
currentTest=`date +%Y%m%d-%H%M`
temp_report_path="/tmp/tsung/$currentTest"
echo "make tsung report directory $temp_report_path"
mkdir -p $temp_report_path
[ -d "$temp_report_path" ] || ( echo "create failed";exit )
#################default value for all parameters
defaultTestFile="$HOME/tsung_test.xml"
defaultUser=50
defaultDuration=30
defaultThinktime=1  # s
defaultServer="LDKJSERVER0012"
defaultPort=9002
defaultApi="/v2/stest5"
defaultMethod="GET"
defaultloop=40
defaultMaxuser=8000
defaultProbabilityGet=100
defaultContents='{"u":"a","mcc":460,"n":"a","by":0,"mnc":1,"lnt":116.345031,"cid":4936921,"lat":39.980952,"lac":41019,"dId":"35513605339286910683F9028B1","x":"3352--10683F9028B1-4075689767927285040"}'

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
#################check if tsung has aready run
getPid(){
  ps aux | grep $1 | grep -v grep | awk '{print $2}'
}
#convert from string to array
pid=$(getPid tsung)
if [ ${#pid[*]} -gt 3 ]; then
  echo "warning!!! a $processName process is running,please wait"
  exit 1
fi
#################restart play server
ssh LDKJSERVER0012 << EOF
"$scriptPath/stop-play-test.sh"
sleep 2
echo "start play..."
"$scriptPath/start-play-test.sh"
sleep 5
exit
EOF
#################set assign value or set default if has no param
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
#ignore lower and upper, attention: [[ ]]
if [[ $method = [Gg][Ee][Tt] ]]; then
  probabilityGet=100
else
  probabilityGet=0
fi
probabilityGet=${probabilityGet:=$defaultProbabilityGet}
probabilityPOST=`expr 100 - $probabilityGet`

#################key of params is nodename in tusng_test.xml file
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
#################prepare test file
cp $testFile $temp_report_path
currentTestFile="$temp_report_path/tsung_test.xml"
function replace(){
  echo "$1:$2" | tee -a "$temp_report_path/test.env"
  #delete backspace
  local val=${2// /}
  #change / to \/ for sed 
  val=${val//\//\\\/}
  val=${val//&/\\&amp;}
  #convert " to &quot;
  val=${val//\"/\\&quot;}
  sed -i "s/@${1}/${val}/" $currentTestFile
}

for key in ${!params[*]}
do
  replace $key ${params[$key]}
done

#start jmeter 
$jmeterRun -s LDKJSERVER0012 -p 9002 -u 1 -r 1 -t 100000000 -l 2 -x 19002 > /dev/null 2>&1 &
jmeter_pid=$!
#start tsung 
tsung -f $currentTestFile start &
tsung_pid=$!
wait_time=`expr 2 \* $loop`

( sleep $wait_time; \
  echo "timeout,tsung will be killed:$tsung_pid"; \
  kill -9 $tsung_pid ; \
  sleep 1; \
  residual_tsung=$(getPid tsung_test.xml); \
  echo "residual tsung:$residual_tsung"; \
  [ -n "$residual_tsung" ] && kill -9 $residual_tsung ) &
deamon_pid=$!

begin=`date`
begin=`date -d  "$begin" +%s`

wait $tsung_pid > /dev/null 2>&1

cd $temp_report_path
/usr/local/lib/tsung/bin/tsung_stats.pl > /dev/null 2>&1

#stop jmeter when tsung is complete
/usr/local/bin/apache-jmeter-2.9/bin/stoptest.sh
wait $jmeter_pid
kill $deamon_pid > /dev/null 2>&1

end=`date`
end=`date -d  "$end" +%s`

current_test_code=`ll $tsung_log_path | tail -n 2 | awk -F' ' '/./ {print $9}'`
current_test_path="$tsung_log_path/$current_test_code"

runtime=`expr $end - $begin`
if [ $runtime -le 60 ]; then
  echo "runtime is $runtime, seems like temp, $temp_report_path will be deleted"
  rm -rf "$current_test_path"
else
  mv "$temp_report_path/*" "$current_test_path"
  newReport="<a href=\"./log/$current_test_code\"> \
    $current_test_code -- api:${api%%\?*} -- loop:$loop user:$user duration:$duration thinktime:$thinktime maxuser:$maxuser \
    </a>\n<br>\n \
    <img src=\"./log/$current_test_code/images/graphes-Transactions-rate_tn.png\" alt=\"http_code_rate\" />\n \ 
    <img src=\"./log/$current_test_code/images/graphes-Perfs-mean_tn.png\" alt=\"perfs-meann\" />\n<br>"
  #insert one line before </body>
  sed -i "/\/body/i\\${newReport}" $HOME/.tsung/index.html
fi
rm -rf $temp_report_path