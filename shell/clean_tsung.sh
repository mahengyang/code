#!/bin/bash

function killall(word){
  pid=`ps aux | grep $word | grep -v grep | awk '{print $2}'`
  if [ -n "$pid" ]; then
  	kill -9 $pid
  fi
}

killall("tsung_test.xml")
killall("jmeter")
