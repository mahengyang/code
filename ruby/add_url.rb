#!/usr/local/bin/ruby
# encoding: utf-8

require 'mongo'
require 'mysql2'

print "快拿id："
zapyaId = gets.chomp

print "共享名称:"
# sname = gets.chomp
sname = '功夫影子'

print "云端url："
url=gets.chomp

currentTime = Time.now.to_i * 1000
db = Mongo::Connection.new("LDKJSERVER0005", 44001).db("zapya_api")
puts "set #{zapyaId}`s #{sname} #{url}"
sharing = db['sharings'].find({"zapyaId"=>"#{zapyaId}","rm" => false,"n" => /#{sname}/})

sid = ""
sharing.each{ |row|
	puts row
	sid = row["_id"]
}

# 添加url
db["sharings"].update(
	{"zapyaId"=>"#{zapyaId}","rm" => false,"n" => /#{sname}/},
	{"$set"=>{"u"=>"#{url}"}}
)

puts "===========sharing u@=#{currentTime}=========="
# 修改时间戳
db.["sharings"].update(
	{"zapyaId"=>"#{zapyaId}","_id"=>"#{sid}"},
	{"$set"=>{"u@"=>"#{currentTime}"}})

puts "==============mysql share_updated_at=#{currentTime}============="
# 修改mysql时间戳
mysql = Mysql2::Client.new(:host => "LDKJSERVER0007", :username => "dewmobile",:password=>"dewmobile",:database=>"fastooth")
mysql.query("update users set share_updated_at=#{currentTime} where _id=#{zapyaId};")

