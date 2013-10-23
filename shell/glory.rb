#!/usr/local/bin/ruby
require "mongo"
require "mysql2"

gloryFile = "/tmp/glory.data"
zapyaId = $*[0]
db = Mongo::Connection.new("LDKJSERVER0005", 44001).db("zapya_api")
mysql = Mysql2::Client.new(:host => "LDKJSERVER0007", :username => "dewmobile",:password=>"dewmobile",:database=>"fastooth")
maxUserId = nil
db["idGenerator"].find().each{|row| 
	maxUserId = row["userId"]
}
minUserId = 10000001
maxZombie = 6
minZombie = 1
currentTime = Time.now.to_i * 1000
f = File.open(gloryFile,"a")
# 为类型为app的共享随机增加被拿数
db["sharings"].find({zapyaId:"#{zapyaId}",rm:false,cat:4}).each { |row|
	# 随机数小于0.6，则跳过此app（随机挑一部分app增加被拿数）
	next if rand() < 0.6
	resource = row["_id"]
	# 随机获取10个到2个僵尸
	zombiesNumber = rand(maxZombie - minZombie) + minZombie
	zombies = Array.new
	zombiesNumber.times{ 
		id = rand(maxUserId - minUserId) + minUserId 
		zombies.push id if id != zapyaId
	}
	line = "#{zapyaId} #{resource} #{zombies.join(",")}"
	puts line
	f.puts line
	
	# 修改单个共享的被拿数
	db["sharings"].update({zapyaId:"#{zapyaId}",_id:"#{resource}"},{"$inc"=>{"#g"=>zombies.size}})
	db["sharings"].update({zapyaId:"#{zapyaId}",_id:"#{resource}"},{"$set"=>{"u@"=>currentTime}})
	
	# 修改用户总的被拿数
	db["hotUsers"].update({_id:"#{zapyaId}"},{"$inc"=>{"#s"=>zombies.size}})
	
	#添加僵尸
	zombies.each{ |zombie|
	  db["sharingStatByUsers"].update({f:"#{zapyaId}",t:"#{zombie}"},{"$inc"=>{"#s"=>1}},{upsert:true})
	  db["sharingStats"].insert({"c@"=>currentTime,"f"=>"#{zapyaId}","st"=>1,"zapyaId"=>"#{zombie}","sid"=>"#{resource}"})
	}
}
f.close
mysql.query("update users set share_updated_at=#{currentTime} where _id=#{zapyaId};")