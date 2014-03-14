#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'csv'

page_number = 1..10000
first_letter = %W(a b c d e f g h i j k l m n o p q r s t u v w x y z)
singer_id_file = CSV.open('kuwo_singer.csv','w')
max_page_number = 0
first_letter.each do |letter|
  page_number.each do |n|
    url = "http://www.kuwo.cn/mingxing/0_#{letter}_#{n}.htm"
    page = Nokogiri::HTML(open(url))
    if n == 1
      tail = page.css('div.numTab a')
      max_page = tail[ tail.length - 2]
      if max_page.nil?
        max_page_number = 1
      else
        max_page_number = max_page.text.to_i
      end
    end
    puts "#{letter} == #{n} == #{max_page_number}"
    break if n > max_page_number

    page.css('div.qu_list a.qu_pho').each do |item|
      singer_name = item['title']
      singer_href = item['href']
      singer_id_file << [letter,singer_name,singer_href]
    end

    page.css('div.numItem ul li a').each do |item|
      singer_name = item['title']
      singer_href = item['href']
      singer_id_file << [letter,singer_name,singer_href]
    end
  end 
end
