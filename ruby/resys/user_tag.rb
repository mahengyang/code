#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'mongo'

class User_tag

	def initialize
		@db = Mongo::Connection.new("192.168.11.8", 44001).db("zapya_api")
		@source_coll = @db['sharings.app']
		@tags_coll = @db['qing.keywords']
	end

	def find_item(user)
		records = @source_coll.find({zapyaId:user})
		@items = records.map{ |r| r['n'] }
	end

	def find_tags(items)
		tags = []
		@items.map { |e| 
			records = @tags_coll.find({app:e}) 
			records.each do |r| 
				tag = r['dtag']
				next if tag.nil? or tag.empty?
				tags = tags + tag
			end
		}

		tags.group_by{|k| k}.map{|k,v| [k, v.length]}.sort_by{|i| -i[1]}
	end
end

id = ARGV[0].to_i
user = User_tag.new 
items = user.find_item(id)
tags = user.find_tags(items)
puts "user id: #{id}"
puts "user has: #{items}"
puts "========== tags =============="
puts "#{tags}"
