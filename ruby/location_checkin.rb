#!/usr/bin/env ruby
require 'net/http'
require 'base64'
require 'json'

req_headers = {
	'Authorization' => 'def7c5b70f04287effaaa402ecf9cd51',
	'Content-Type' => 'application/json',
       # "cookie" => 'authToken=9a9fa8f82ffe0f43bccd7ee0245ba1a6; Path=/',
	"cookie" => 'authToken=4b2bd7dd0b0031ff7684c69e8a398bfa; Path=/',
	"X-DevId" => '111',
	"X-UserTag" => "999901999999",
       # 'X-SID' => 'D4EE070100D4',
	'X-SID' => 'aaa',
}
req_body = '{
              "lnt": 1,
              "lat": 1,
              "u": 1,
              "n": 1,
              "m": 3,
              "limit": 20,
              "offset": 0,
              "by": 0,
              "x": "xx"
			}'
# convert image to base64 code
req_body = JSON::Parser.new(req_body).parse

# http connect to zapya test server
# http = Net::HTTP.new('211.151.121.183' , 80)
http = Net::HTTP.new('localhost' , 9000)
response = http.request_post('/v2/locations/checkin', JSON::generate(req_body), req_headers)

puts "\n==============http header==============\n#{req_headers}"
puts "\n==============http body==============\n#{JSON::generate(req_body)}"
puts "\n==============response==============\n#{response}"
puts "\n==============response.body==============\n#{response.body}"
