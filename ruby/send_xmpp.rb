#!/usr/bin/env ruby
require 'rjb'
require 'json'
require 'mongo'
require 'net/http'

# receiver = "10556096"
receiver = "10000063"
sender = "10000001"

req_headers = {
	'Authorization' => 'def7c5b70f04287effaaa402ecf9cd51',
	'Content-Type' => 'application/json',
	"cookie" => 'authToken=980a4d9905b995f575e80e6bc17558ee; Path=/',
	"X-DevId" => '111',
	"X-UserTag" => "999901999999"
}

Rjb::load(classpath = '/home/deployer/DmCodec.jar', jvmargs=[])
DmCodec = Rjb::import('com.zapya.DmCodec').new

message = '{
			"to": {
        		"+": ""
    		},
    		"m": "",
    		"t": 3
			}'
m = '{
   "f": 0,
   "t": 5,
   "text": ""
   }'
text = '{
   		"n":"dcb",
   		"text":{
   			"ot":1,
   			"cat":4,
   			"rm":true,
   			"op":"/data/app/com.kascend.video-1.apk",
   			"c":"",
   			"pkg":"com.kascend.video",
   			"o":"8426475",
   			"oz":"10556054",
   			"th":["1284"],
   			"t":"开迅视频",
   			"nd":false,
   			"pz":"10556054",
   			"p":"8426475",
   			"pt":1,
   			"st":0
   		},
   		"from":"愿望",
   		"s":1,
   		"z":"10000035"
   		}'
req_body = JSON::Parser.new(message).parse
text = JSON::Parser.new(text).parse
m = JSON::Parser.new(m).parse
req_body['to']['+'] = receiver
text["n"] = "xxx";
text["text"]["oz"]=receiver
text["text"]["pz"]=receiver
text['z'] = sender

m["text"] = DmCodec.encodeB62(JSON::generate(text))
p "****************",m,"***************"
req_body["m"] = m

http = Net::HTTP.new('LDKJSERVER0003' , 80)
response = http.request_post('/v2/push', JSON::generate(req_body), req_headers)

puts "\n==============http header==============\n#{req_headers}"
puts "\n==============http body==============\n#{JSON::generate(req_body)}"
puts "\n==============response==============\n#{response}"
puts "\n==============response code ==============\n#{response.code}"
puts "\n==============response.body==============\n#{response.body}"