package com.ma;

import redis.clients.jedis.Jedis;
import java.util.Iterator;
import java.util.Set;

/**
 * Created by ma on 2015/10/26.
 */
public class Main {

    public static void main(String args[]){
        String readRedis = "172.16.3.187";
//        String readRedis = "192.168.7.191";
        String masterRedis = "172.16.3.186";
//        String masterRedis = "192.168.7.191";
        // 超时时间10min
        int timeout = 30;
        Jedis jedisRead = null;
        try {
            jedisRead = new Jedis(readRedis,6379,timeout * 60 * 1000);
        }catch (Exception e) {
            System.out.println(readRedis+"连接异常");
            System.exit(1);
        }
        Jedis jedisMaster = null;
        try {
            jedisMaster = new Jedis(masterRedis) ;
        }catch (Exception e) {
            System.out.println(masterRedis+"连接异常");
            System.exit(1);
        }


        System.out.println("备份库" + readRedis + " dbSize: " + jedisRead.dbSize());
        System.out.println("主库"+masterRedis + " dbSize: " + jedisMaster.dbSize());

        Set<byte[]> keys = null;
        try {
            System.out.println("从备份库" + readRedis + "读取key，keys(\"[^tickets]*\")");
            keys = jedisRead.keys("[^tickets]*".getBytes());
        }catch (Exception e) {
            System.out.println(readRedis+"连接异常");
            System.exit(1);
        }
        System.out.println("待删除key的数量：" + keys.size());

        System.out.println("准备删除"+masterRedis+"中的序列化key");

        Iterator<byte[]> it = keys.iterator();
        while(it.hasNext()){
            byte[] key = it.next();
            Long result = jedisMaster.del(key);
            System.out.println(result);
        }
    }
}
