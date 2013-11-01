#!/usr/bin/env ruby
require 'net/http'
require 'base64'
require 'json'

req_headers = {
	'Authorization' => '2f43cea8c486e24df9f712e016356b3d',
	'Content-Type' => 'application/json',
	# new header
	'X-SID' => 'aaa',
}
req_body = '{"i":"aaa",
			 "cl":[{"cat":3,
			 		"pkg":"com.dewmobile.zapya",
			 		"n":"快拿",
			 		"s":8016787,
			 		"url":"http://station1",
			 		"thumb":"E:/Github/code/img/small.png"
			 		},
				   {"cat":4,
				   	"pkg":"com.dewmobile.kuaiya",
				   	"n":"快牙",
				   	"s":8779500,
				   	"url":"http://station2",
				   	"thumb":"E:/Github/code/img/small.png"
				   	}
				  ]
			}'
# convert image to base64 code
req_body = JSON::Parser.new(req_body).parse
req_body['cl'].each { |share|
	imagePath = share['thumb']
	share['thumb'] = Base64::encode64(File.open(imagePath,'rb').read).gsub(/\n/,'')
}
# http connect to zapya test server
http = Net::HTTP.new('211.151.121.183' , 80)
if $*[0] == 'register'
	puts '============== register =============='
	response = http.request_post('/v2/stations', JSON::generate(req_body), req_headers)
elsif $*[0] == 'update'
	puts '============== update =============='
	response = http.request_put('/v2/stations/10556083', JSON::generate(req_body), req_headers)
end

puts "\n==============http header==============\n#{req_headers}"
puts "\n==============http body==============\n#{JSON::generate(req_body)}"
puts "\n==============response==============\n#{response}"
puts "\n==============response.body==============\n#{response.body}"
