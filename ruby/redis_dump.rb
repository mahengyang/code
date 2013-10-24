#!/usr/local/bin/ruby

=begin
  * Description: 导出redis数据库中的数据
  * Author: enyo
  * Date: 2013-10-24
  * License:
=end

require 'redis'

redis = Redis.new(:host => "LDKJSERVER0006", :port => 6380, :db => 5)
File.open('/tmp/baseStation.data','w'){ |f|

	redis.keys('*').each { |baseStation|
		coord = redis.hgetall(baseStation)
		f.puts "#{coord['lnt']} #{coord['lat']}"
	}
}
