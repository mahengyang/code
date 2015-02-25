package com.user;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

/**
 * Created by mahengyang on 2015/2/11 0011.
 */
public class Test {
    private int pooSize = 30;
    public Test(int pooSize){
        this.pooSize = pooSize;
    }
    public void run(ArrayList<String> usernames){
        ExecutorService pool = Executors.newFixedThreadPool(this.pooSize);
        List<FutureTask<String>> list = new ArrayList<FutureTask<String>>();
        for (String username : usernames){
            FutureTask<String> task = new FutureTask<String>(new Task(username));
            list.add(task);
            pool.execute(task);
        }
        for(FutureTask<String> f : list){
            try {
                System.out.println(f.get());
            }catch (Exception e){
                System.out.println("获取future结果错误");
            }
        }
    }
    public static void main(String[] args){
        System.out.println("并发调用user/{username}/get");
        ArrayList<String> usernames = new ArrayList<String>();
        for (int i=0; i<200; i++) {
            usernames.add("344fffffff");
            usernames.add("15951861145");
        }
        Test test = new Test(10);
        for(int i=0;i<20;i++){
            test.run(usernames);
            System.out.println("执行完毕");
        }
        Runtime.getRuntime().halt(0);
    }

    private class Task implements Callable<String>{
        String username;
        public Task(String username){
            this.username = username;
        }
        @Override
        public String call(){
            String url = "http://user:7070/api/user/" + this.username+"/get";
            //System.out.println("run call:"+url);
            HttpClient httpClient = new HttpClient();
            httpClient.setTimeout(1000);
            GetMethod get = new GetMethod(url);
            try {
                int status = httpClient.executeMethod(get);
                if(status == 500){
                    return "500";
                }
                return get.getResponseBodyAsString();
            }catch(Exception e){
            }finally {
                if (httpClient != null)
                    get.releaseConnection();
            }
            return "";
        }
    }
}
