#!/usr/bin/env ruby
require 'json'
require 'mongo'

db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
dir = ARGV[0] 
Dir.open(dir).each do |f|
  next if [".",".."].include?(f)
  file_name = dir + f
  File.open(file_name, 'r').each do |row|
    result = JSON.parse(row)
    result['data'].each do |song|
      db['ma.music1'].insert(song)
    end
  end
end
