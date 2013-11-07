#!/usr/bin/env ruby
require 'json'
require 'mongo'
require 'net/http'
require 'redis'

class SendXmppMessage

  def initialize(mysql)
    @http = Net::HTTP.new("LDKJSERVER0014" , 80)
    @redis = Redis.new(:host => "LDKJSERVER0014", :port => 6379)
    @mysql = mysql
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
       "text": "",
       "ec":false
       }'

    text = '{
          "n":"dcb",
          "text":{
            "ot":1,
            "cat":4,
            "rm":true,
            "op":"",
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

    @message = JSON::Parser.new(message).parse
    @text = JSON::Parser.new(text).parse
    @m = JSON::Parser.new(m).parse

    @req_headers = {
      'Authorization' => 'def7c5b70f04287effaaa402ecf9cd51',
      'Content-Type' => 'application/json',
      "cookie" => "authToken=f329ad4748ca160ece0f36f4c8f77469; Path=/",
      "X-DevId" => '111',
      "X-UserTag" => "999901999999"
    }
  end

  def send_request(sender,receiver,sharing)
    result = @mysql.query("select display_name,auth_token from users where _id=#{sender}")
    sender_info = {}
    result.each{ |row|
      sender_info = row
    }
    p sender_info
    p sharing
    @redis.set('login:',{sender_info["auth_token"] => sender})
    @req_headers['cookie'] = "authToken=#{sender_info['auth_token']}; Path=/"

    @message['to']['+'] = receiver
    @text["n"] = sender_info['display_name'];
    @text['z'] = sender

    @text["text"]["oz"] = receiver
    @text["text"]["pz"] = receiver
    @text["text"]["cat"] = sharing["cat"].to_s
    @text["text"]["pkg"] = sharing["pkg"]
    @text["text"]["th"] = sharing["th"].to_s
    @text["text"]["t"] = sharing["n"]

    @text["text"] = JSON::generate(@text["text"])
    @m["text"] = JSON::generate(@text)
    p "****************",@m,"***************"
    @message["m"] = @m

    response = @http.request_post('/v2/push', JSON::generate(@message), @req_headers)

    puts "\n==============http header==============\n#{@req_headers}"
    puts "\n==============http body==============\n#{JSON::generate(@message)}"
    puts "\n==============response==============\n#{response}"
    puts "\n==============response code ==============\n#{response.code}"
    puts "\n==============response.body==============\n#{response.body}"
  end
end