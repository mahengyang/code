#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'csv'

page_number = 1..10000
first_letter = %W(a b c d e f g h i j k l m n o p q r s t u v w x y z)
singer_id_file = CSV.open('kugou_singer','w')
first_letter.each do |letter|
  page_number.each do |n|
    url = "http://www.kugou.com/yy/singer/index/#{n}-#{letter}-1.html"
    page = Nokogiri::HTML(open(url))
    tail = page.css('ul#list_head').text
    break if tail == '暂无记录'
    page.css('ul#list_head li a.pic').each do |item|
      singer_id = item['href'].gsub(/\D/,'').to_i
      singer_name = item['title']
      singer_rank = item.css('i').text
      singer_rank.gsub!(/\D/,'')
      singer_id_file << [letter,singer_id,singer_name,singer_rank.to_i]
    end
    page.css('ul.list1 li').each do |item|
      a = item.css('a.text')[0]
      singer_id = a['href'].gsub(/\D/,'').to_i
      singer_name = a['title']
      singer_rank = item.css('span.ran').text
      singer_id_file << [letter,singer_id,singer_name,singer_rank.to_i]
    end
  end 
end
