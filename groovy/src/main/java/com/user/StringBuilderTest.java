package com.user;

/**
 * Created by mahengyang on 2015/2/11 0011.
 */
public class StringBuilderTest {

    public static void main(String[] args){
        int count = 10;
        System.out.println("String + StringBuilder");
        String a = "";
        long t1 = System.currentTimeMillis();
        for (int i=0; i<count; i++) {
            a = a + count;
        }
        long t2 = System.currentTimeMillis();
        System.out.println("String +: " + (t2 - t1));
        

        StringBuilder sb = new StringBuilder();
        long t3 = System.currentTimeMillis();
        for(int i=0;i<count;i++){
            sb.append(String.valueOf(count));
        }
        String result = sb.toString();
        long t4 = System.currentTimeMillis();
        System.out.println("StringBuilder: " + (t4 - t3));
        Runtime.getRuntime().halt(0);
    }
}
