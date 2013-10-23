#!/usr/bin/ruby
require 'net/http'
require 'base64'
require 'json'

req_headers = {
	'Authorization' => '2f43cea8c486e24df9f712e016356b3d',
	'Content-Type' => 'application/json',
	# new header
	'X-DevId' => '1',
}
puts "\n==============http header==============\n#{req_headers}"
req_body = '{"i":"test",
			 "cl":[{"cat":3,
			 		"pkg":"com.dewmobile.zapya11",
			 		"n":"快拿",
			 		"s":8016787,
			 		"url":"http://station1",
			 		"thumb":"E:/Github/code/img/iGoogle.png"
			 		},
				   {"cat":4,
				   	"pkg":"com.dewmobile.kuaiya11",
				   	"n":"快牙",
				   	"s":8779500,
				   	"url":"http://station2",
				   	"thumb":"E:/Github/code/img/iGoogle.png"
				   	}
				  ]
			}'
req_body = JSON::Parser.new(req_body).parse
req_body['cl'].each { |share|
	imagePath = share['thumb']
	share['thumb'] = Base64::encode64(File.open(imagePath,'rb').read).gsub(/\n/,'')
}
puts "\n==============http body==============\n#{JSON::generate(req_body)}"
# http = Net::HTTP.new('ubuntu' , 9000)
http = Net::HTTP.new('211.151.121.181' , 9000)
if $*[0] == nil
	response = http.request_post('/v2/stations', JSON::generate(req_body), req_headers)
else
	response = http.request_put('/v2/stations/10556083', JSON::generate(req_body), req_headers)
end
puts "\n==============response==============\n#{response}"
puts "\n==============response.body==============\n#{response.body}"
