#!/usr/bin/env ruby
# encoding: utf-8 
require 'mongo'

db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
File.open('/media/puffin/mycode/ruby/crawler/kugou_singer_id', 'r').each do |row|
  id,singer_name = row.chomp.split ','
  db['kugou.singer'].insert({"_id" => id,"singer_name" => singer_name})
end
