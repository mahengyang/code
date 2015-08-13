package com.user;
import redis.clients.jedis.Jedis;

def redisOld = '192.168.7.239'
def redisNew = '192.168.7.4'
def prefix = '>>>>>>>>'
println "$prefix 开始比较redis中的key old redis: $redisOld new redis: $redisNew"
Jedis jedisOld = new Jedis(redisOld)
def keysOld = jedisOld.keys("*")
println keysOld
Jedis jedisNew = new Jedis(redisNew)
def keysNew = jedisNew.keys("*")
def common = keysNew.intersect keysOld

def n  = keysNew - common
def o = keysOld - common
if (n.size() == 0 && o.size() == 0) {
	println "$prefix 两个redis中的key全部相同"
}else{
	println "$prefix new redis 独有的 keys"
	n.each{ k ->
		println k
	}
	println "$prefix old redis 独有的 keys"
	o.each { k ->
		println k
	}
}