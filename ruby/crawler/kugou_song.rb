#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'json'

page_number = 1..1000
File.open('kugou_singer_id','r').each do |row|
  singer_id = row.split(',')[0].to_i
  song_file = File.open("kugou_song/#{singer_id}",'w')
  page_number.each do |n|
    url = "http://www.kugou.com/yy/?r=singer/song&sid=#{singer_id}&p=#{n}&t=#{Time.now.to_i * 1000}"
    page = Nokogiri::HTML(open(url))
    result = page.css('body p').text

    break if result.size < 50
    song_file.puts result 
  end 
end
