#!/usr/bin/env ruby
# encoding: utf-8
require 'csv'
require 'mongo'
require 'redis'

db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
redis12 = Redis.new(:host => "localhost",:port => 6379, :db => 12)
redis13 = Redis.new(:host => "localhost",:port => 6379, :db => 13)
result = File.new('/media/puffin/other/probs-result','wb')

users = redis12.keys "*"

users.each do |user|
  items = []
  result.puts "=============================== #{user} has ============================"
  redis12.smembers(user).each do |item|
    item = item.to_i
    id = db['audioId'].find_one({"_id" => item})
    result.puts id['n']
  end
  items_p = redis13.hgetall user
  next if items_p.nil?
  predict = {}
  result.puts "**************** recommand ********************"

  items_p.each do |item_p, score|
    score = score.to_f
    next if score.to_f < 0.01
    item_p = item_p.to_i
    predict[db['audioId'].find_one({_id:item_p})['n']] = score.round(3)
  end
  t = predict.sort {|a1,a2| a2[1]<=>a1[1]}
  t.each do |k,v|
    result.puts "#{v}  #{k}"
  end
end