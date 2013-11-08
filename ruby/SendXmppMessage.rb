#!/usr/bin/env ruby
require 'json'
require 'mongo'
require 'net/http'
require 'redis'
require 'rjb'

class SendXmppMessage

  def initialize
    @http = Net::HTTP.new("LDKJSERVER0004" , 80)
    Rjb::load(classpath = '/home/deployer/DmCodec.jar', jvmargs=[])
    @dmCodec = Rjb::import('com.zapya.DmCodec').new
  end

  def send_request(sender,receiver,sharing)
    puts "===============#{sender} send xmpp to #{receiver}================="
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
            "t":"",
            "nd":false,
            "pz":"10556054",
            "p":"8426475",
            "pt":1,
            "st":0
          },
          "from":"",
          "s":1,
          "z":"10000035"
          }'

    message = JSON::Parser.new(message).parse
    text = JSON::Parser.new(text).parse
    m = JSON::Parser.new(m).parse

    req_headers = {
      'Authorization' => 'def7c5b70f04287effaaa402ecf9cd51',
      'Content-Type' => 'application/json',
      "cookie" => "authToken=f329ad4748ca160ece0f36f4c8f77469; Path=/",
      "X-DevId" => '111',
      "X-UserTag" => "999901999999"
    }

    req_headers['cookie'] = "authToken=#{sender['auth_token']}; Path=/"

    message['to']['+'] = receiver
    text["n"] = @dmCodec.decodeB62(sender['display_name'])
    text['from'] = text['n']
    text['z'] = sender['id']

    text["text"]["oz"] = receiver
    text["text"]["pz"] = receiver
    text["text"]["cat"] = sharing["cat"].to_s
    text["text"]["pkg"] = sharing["pkg"]
    text["text"]["th"] = sharing["th"].to_s
    text["text"]["t"] = sharing["n"]
    tmp = JSON::generate(text["text"])
    text["text"] = tmp
    m["text"] = JSON::generate(text)
    message["m"] = m

    response = @http.request_post('/v2/push', JSON::generate(message), req_headers)

    puts "\n==============http header==============\n#{req_headers}"
    puts "\n==============http body==============\n#{JSON::generate(message)}"
    puts "\n==============response==============\n#{response}"
    puts "\n==============response code ==============\n#{response.code}"
    puts "\n==============response.body==============\n#{response.body}"
  end
end
