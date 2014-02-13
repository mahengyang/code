#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'

page_number = 1..10000
first_letter = %W(a b c d e f g h i j k l m n o p q r s t u v w x y z)
singer_id_file = File.open('kugou_singer_id','w')
first_letter.each do |letter|
  page_number.each do |n|
    url = "http://www.kugou.com/yy/singer/index/#{n}-#{letter}-1.html"
    page = Nokogiri::HTML(open(url))
    tail = page.css('ul#list_head').text
    break if tail == '暂无记录'
    page.css('ul#list_head li a.pic').each do |item|
      singer_id = item['href'].gsub(/\D/,'').to_i
      singer_name = item['title']
      singer_id_file.puts "#{singer_id},#{singer_name}"
    end
    page.css('ul.list1 li a').each do |item|
      singer_id = item['href'].gsub(/\D/,'').to_i
      singer_name = item['title']
      singer_id_file.puts "#{singer_id},#{singer_name}"
    end
  end 
end
