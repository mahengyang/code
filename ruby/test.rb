#!/usr/bin/env ruby
require 'csv'
=begin
  * Description: 导出redis数据库中的数据
  * Author: enyo
  * Date: 2013-10-24
  * License:
=end

require 'redis'

redis = Redis.new(:host => "localhost", :port => 6379, :db => 14)
CSV.open(ARGV[0],'wb'){ |f|
	redis.keys('*').each { |singer|
		value = redis.hgetall(singer)
    next if value.length < 10
    value.each { |k,v|
      v = v.to_f.round 4
      next if v < 0.08
  		f << [singer, k, v.to_f.round(4)]
    }
	}
}
