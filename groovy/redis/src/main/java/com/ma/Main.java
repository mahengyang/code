package com.ma;

import org.apache.commons.cli.*;
import redis.clients.jedis.Jedis;
import java.util.Iterator;
import java.util.Set;

/**
 * Created by ma on 2015/10/26.
 */
public class Main {

    public static void help(){
        System.out.println("-r | --read 从哪个redis库读取key");
        System.out.println("-w | --write 从哪个redis库删除key");
        System.out.println("-q | --query 查询条件");
        System.out.println("-h | --help 查看帮助");
        System.exit(0);
    }
    public static void main(String args[]){
        CommandLineParser parser = new BasicParser( );
        Options options = new Options( );
        options.addOption("r", "read", true, "指定读库");
        options.addOption("w", "write", true, "指定写库");
        options.addOption("q", "query", true, "查询条件");
        options.addOption("h", "help", false, "help");
        CommandLine commandLine = null;
        try {
            commandLine = parser.parse( options, args );
        } catch (ParseException e) {
            System.out.println("参数解析错误");
            System.exit(1);
        }
        if (commandLine.hasOption("h")) {
            help();
        }
        if (!commandLine.hasOption("r") || !commandLine.hasOption("w") || !commandLine.hasOption("q")){
            System.out.println("必须指定redis数据库和查询条件");
            help();
            System.exit(1);
        }
        String readRedis = commandLine.getOptionValue("r");
        String masterRedis = commandLine.getOptionValue("w");
        String query = commandLine.getOptionValue("q");
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

        try {
            System.out.println("备份库" + readRedis + " dbSize: " + jedisRead.dbSize());
        }catch (Exception e) {
            System.out.println(readRedis+" 连接异常");
            System.out.println(e.getLocalizedMessage());
            System.exit(1);
        }

        try {
            System.out.println("主库"+masterRedis + " dbSize: " + jedisMaster.dbSize());
        }catch (Exception e) {
            System.out.println(masterRedis+" 连接异常");
            System.out.println(e.getLocalizedMessage());
            System.exit(1);
        }

        Set<byte[]> keys = null;
        try {
            System.out.println("从备份库" + readRedis + "读取key，keys("+query+")");
            keys = jedisRead.keys(query.getBytes());
        }catch (Exception e) {
            System.out.println(readRedis+"执行keys操作异常退出");
            System.out.println(e.getLocalizedMessage());
            System.exit(1);
        }
        System.out.println("待删除key的数量：" + keys.size());

        System.out.println("准备删除"+masterRedis+"中的key");

        Iterator<byte[]> it = keys.iterator();
        while(it.hasNext()){
            byte[] key = it.next();
            Long result = jedisMaster.del(key);
            System.out.println(result + " " + new String(key));
        }
    }
}
