#!/bin/sh
timeout()
{
        waitfor=3
        command=$*
        $command &
        commandpid=$!
        ( sleep $waitfor; echo "kill pid:$commandpid"; kill -9 $commandpid > /dev/null 2>&1 ) &
        wait $commandpid > /dev/null 2>&1 
}
test_another(){
				echo "this is another"
				sleep 10
				echo "after test_another()"
}	
tsung_test(){
				echo "begin tsung test"
				test_another &
        sleep 10
				echo "after tsung_test()"
}
 
#timeout tsung_test
getPid(){
  ps aux | grep $1 | grep -v grep | awk '{print $2}'
}
echo "pid function return $(getPid noshell)"
