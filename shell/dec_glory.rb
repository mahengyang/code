#!/usr/local/bin/ruby
require "mongo"
require "mysql2"

gloryFile = "/tmp/staging_glory.data"
targetUser = $*[0]
db = Mongo::Connection.new("LDKJSERVER0012", 64003).db("zapya_api")
mysql = Mysql2::Client.new(:host => "LDKJSERVER0014", :username => "dewmobile",:password=>"dewmobile",:database=>"fastooth")
currentTime = Time.now.to_i * 1000

File.open(gloryFile, "r") { |file| 
	file.each_line do |line|
		line = line.split(" ")
		zapyaId = line[0]
		next if ! zapyaId.eql? targetUser
		resource = line[1]
		zombies = line[2].split(",")
		# 减少单个共享的被拿数
		db["sharings"].update({zapyaId:"#{zapyaId}",_id:"#{resource}"},{"$inc"=>{"#g"=>-zombies.size}})
		db["sharings"].update({zapyaId:"#{zapyaId}",_id:"#{resource}"},{"$set"=>{"u@"=>currentTime}})
		
		# 减少用户总的被拿数
		db["hotUsers"].update({_id:"#{zapyaId}"},{"$inc"=>{"#s"=>-zombies.size}})
		
		#删除僵尸
		zombies.each{ |zombie|
		  db["sharingStatByUsers"].update({f:"#{zapyaId}",t:"#{zombie}"},{"$inc"=>{"#s"=>-1}})
		  db["sharingStatByUsers"].find({f:"#{zapyaId}",t:"#{zombie}"}).each{|item|
		  	db["sharingStatByUsers"].remove({f:"#{zapyaId}",t:"#{zombie}"}) if item["#s"] < 1
		  }

		  db["sharingStats"].remove({"f"=>"#{zapyaId}","st"=>1,"zapyaId"=>"#{zombie}","sid"=>"#{resource}"})
		}
	end
	mysql.query("update users set share_updated_at=#{currentTime} where _id=#{targetUser};")
}