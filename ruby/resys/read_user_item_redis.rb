#!/usr/bin/env ruby
# encoding: utf-8
require 'csv'
require 'mongo'
require 'redis'

db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
redis12 = Redis.new(:host => "localhost",:port => 6379, :db => 12)
user_item = {}
CSV.foreach('/media/puffin/other/user_item.csv') do |row|
  user,item = row
  items = user_item[user]
  if items.nil?
    items = Set.new
  end
  items.add item
  user_item[user] = items
end
redis12.flushdb
user_item.each do | user, items |
  items.each do |i|
    puts "#{user},#{i}"
    redis12.sadd user,i
  end
end