#!/usr/bin/env ruby
# encoding: utf-8 
require 'mongo'
require 'csv'

db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
CSV.foreach(ARGV[0]) do |row|
  letter,name,url = row
  db['kuwo.singer'].insert({"_id" => name,"url" => url,"letter" => letter})
end
