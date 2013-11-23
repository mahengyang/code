002D:Glory.rb:0A4A:1:14=527D1658:16=47d21313:#!/usr/local/bin/ruby
require "mongo"
require "mysql2"
require "redis"
load "SendXmppMessage.rb"

class Glory
	def initialize()
		puts "initializing..."
		@db = Mongo::Connection.new("LDKJSERVER0005", 44001).db("zapya_api")
		@mysql = Mysql2::Client.new(
			:host => "LDKJSERVER0007", 
			:username => "dewmobile",
			:password=>"dewmobile",
			:database=>"fastooth")
		@currentTime = Time.now.to_i * 1000
		@sendXmppMessage = SendXmppMessage.new
		@redis = Redis.new(:host => "LDKJSERVER0005", :port => 6379)
		@zombies = []
		File.open('/home/deployer/zombies.txt','r').each{ |row|
			id = row.chomp

			result = @mysql.query("select display_name,auth_token from users where _id=#{id}")
			next if result == nil
			sender_info = {}
	    	result.each{ |row|
	    	  sender_info = row
	    	}
			@redis.hset("login:",sender_info["auth_token"], id)
			sender_info['id'] = id
			@zombies.push sender_info
		}
		@ROBOT_ST = 4
	end

	def getTarget()
		query = [
			{"$match"=> 
				{"st"=>
					{"$gt"=>0}
				} 
			},
			{"$group"=> 
				{"_id"=>"$f",
				 "glory"=>
					 {"$sum"=>1}
				}
			},
			{"$match"=> 
				{"glory"=>
					{"$lt"=>10}
				}
			}
		]
		targetUser = db['sharingStats'].aggregate(query)

	end

	# 随机获取10个到2个僵尸
	def getZombie(max=3,min=1)
		zombiesNumber = rand(min..max)
		@zombies.shuffle().slice(0,zombiesNumber)
	end

	def addGlory(zapyaId)
		zapyaId.chomp!
		# 为类型为app的共享随机增加被拿数
		query = {
			"zapyaId"=>"#{zapyaId}",
			"rm"=>false,
			"$or"=>[
				{"dl"=>{
					"$exists"=>true
					}},
				{"u"=>{
					"$ne"=>""
					}}
				],
			}
		add_glory_corsur = 0
		sharings = []
		@db["sharings"].find(query).each { |sharing|
			sharings.push sharing
		}
		# fetch sharings 1-3
		s