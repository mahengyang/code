package com.user;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.Iterator;

/**
 * Created by mahengyang on 2015/2/11 0011.
 */
public class Crawler {

    public static void main(String[] args){
        String url = "http://item.jd.com/1076015994.html";
        Document doc = null;
        try {
            doc = Jsoup.connect(url).get();
            String title = doc.title();
            System.out.println(title);
            Elements elements = doc.select("ul.lh li img");
            Iterator<Element> it = elements.iterator();
            System.out.println("商品图片：");
            while (it.hasNext()){
                Element element = it.next();
                String src = element.attr("src");
                src = src.replace("n5/jfs","n1/jfs");
                System.out.println(src);
            }
//            Elements elementsDesc = doc.select("div.formwork_img img");
            Elements elementsDesc = doc.select("div#J-detail-content");
            Iterator<Element> itDesc = elementsDesc.iterator();
            System.out.println("商品图文详情：");
            while (itDesc.hasNext()){
                Element element = itDesc.next();
//                String src = element.attr("data-lazyload");
                System.out.println(element.html());
            }

        }catch (IOException e){

        }finally {

        }
    }
}
