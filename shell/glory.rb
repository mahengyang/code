#!/usr/local/bin/ruby
require "mongo"
require "mysql2"
load "SendXmppMessage.rb"

class Glory
	@ROBOT_ST = 4
	
	def initialize()
		@db = Mongo::Connection.new("LDKJSERVER0012", 64003).db("zapya_api")
		@mysql = Mysql2::Client.new(
			:host => "LDKJSERVER0014", 
			:username => "dewmobile",
			:password=>"dewmobile",
			:database=>"fastooth")
		@currentTime = Time.now.to_i * 1000
		@sendXmppMessage = SendXmppMessage.new @mysql
		@zombies = Array.new
		File.open('zombies.txt','r').each{ |row|
			@zombies.push row.chomp
		}
	end

	def getTarget()
		[10556096]
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
	def getZombie(max=10,min=1)
		zombiesNumber = rand(min..max)
		@zombies.shuffle().slice(0,zombiesNumber)
	end

	def addGlory(zapyaId,file)
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
		@db["sharings"].find(query).each { |sharing|
			# 随机数小于0.6，则跳过此app（随机挑一部分app增加被拿数）
			next if rand() < 0.6
			sharingId = sharing["_id"]
			zombies = getZombie()
			line = "#{zapyaId} #{sharingId} #{zombies.join(",")}"
			puts line
			file.puts line
			
			#添加僵尸
			zombies.each{ |zombie|
				begin
			 		@db["sharingStats"].insert({
			 			"c@"=>@currentTime,
			 			"f"=>"#{zapyaId}",
			 			"st"=>@ROBOT_ST,
			 			"zapyaId"=>"#{zombie}",
			 			"sid"=>"#{sharingId}"})
			 	rescue => err
			 		puts "duplicate key"
			 	end
				@sendXmppMessage.send_request(zombie, zapyaId, sharing)
			}
			# 更新时间戳
			@db["sharings"].update({
				zapyaId:"#{zapyaId}",
				_id:"#{sharingId}"},
				{"$set"=>{"u@"=>@currentTime}
				})

		}
		@mysql.query("update users set share_updated_at=#{@currentTime} where _id=#{zapyaId};")
	end

end

glory = Glory.new()
log = File.open('/tmp/glory.log','a')
File.open('/home/deployer/target.data','r').each{|zapyaId|
	glory.addGlory(zapyaId,log)
}
log.close