#!/usr/bin/env ruby
require 'net/http'
require 'json'

req_headers = {
	'Authorization' => 'def7c5b70f04287effaaa402ecf9cd51',
	'Content-Type' => 'application/json',
	"cookie" => 'authToken=4b2bd7dd0b0031ff7684c69e8a398bfa; Path=/',
	"X-DevId" => '111',
	"X-UserTag" => "999901999999",
	'X-SID' => 'aaa',
}
req_body = {
       t: 1,
       n: "test",
       cat: 3,
       snip: "",
       ch: "2000",
       bu: "http://www.youku.com",
}
# req_body = JSON::Parser.new(req_body).parse
# http connect to zapya test server
http = Net::HTTP.new(ARGV[0],ARGV[1])
# response = http.request_post(ARGV[2], JSON::generate(req_body), req_headers)
response = http.request_get(ARGV[2], req_headers)
puts "\n==============http header==============\n#{req_headers}"
puts "\n==============http body==============\n#{JSON::generate(req_body)}"
puts "\n==============response==============\n#{response}"
puts "\n==============response msg==============\n#{response.msg}"
puts "\n==============response header==============\n#{response['location']}"
puts "\n==============response.body==============\n#{response.body}"
