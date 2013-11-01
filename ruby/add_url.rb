require 'mongo'
require 'mysql2'

param = $!
currentTime = Time.now.to_i * 1000
db = Mongo::Connection.new("LDKJSERVER0005", 44001).db("zapya_api")
# 添加url
db.sharings.update(
	{"zapyaId"=>"#{zapyaId}","_id":"#{sid}"},
	{"$set":{"u"=>"#{url}"}}
)
# 修改时间戳
db.sharings.update({zapyaId:"zapyaId",_id:"sid"},{$set:{"u@":"#{currentTime}"}})
# 修改mysql时间戳
mysql = Mysql2::Client.new(:host => "LDKJSERVER0007", :username => "dewmobile",:password=>"dewmobile",:database=>"fastooth")
mysql.query("update users set share_updated_at=#{currentTime} where _id=#{zapyaId};")

