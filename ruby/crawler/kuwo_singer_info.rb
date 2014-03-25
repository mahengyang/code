#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'json'
require 'csv'
require 'mongo'

mongodb = Mongo::Connection.new("localhost", 44001).db("zapya_api")
kuwo_singer_coll = mongodb['kuwo.singer']
#kuwo_singer_coll.drop()
kuwo_tabs_coll = mongodb['kuwo.tabs']
#kuwo_tabs_coll.drop()

user_attribute = {
  '性别' => 'gender',
  '别名'=>'alias',
  '国籍'=>'country',
  '语言'=>'language',
  '出生地'=>'birthplace',
  '生日'=>'birthday',
  '星座'=>'constellation',
  '身高'=>'stature',
  '体重'=>'weight'
}
id = 1
CSV.foreach(ARGV[0]) do |row|
  letter,name,singer_url = row
  puts "singer:#{name}"
  recorder = {_id:id, singer: name, url:singer_url, letter:letter, length:name.length}
  begin
    doc = Nokogiri::HTML(open(singer_url))
    t = doc.css('div.w1000')
    if t.nil? or t.empty?
      kuwo_singer_coll.insert(recorder)
      id = id + 1
      next
    end
  rescue => error
    next
  end
  tmp = doc.css('div.mBodFrm4 p.gzBtnCont')
  next if tmp.nil?
  rank_index = 1
  if tmp.length == 1
    rank_index = 0
  end
  singer_tab_dom = tmp[0]
  singer_tabs = []
  singer_tab_dom.css('a').each do |item|
    tab_url = item['href']
    tab = item.text
    kuwo_tabs_coll.save({_id:tab, url:tab_url})
    singer_tabs.push tab
#   puts "#{tab},#{tab_url},#{name}"
  end
  recorder['tabs'] = singer_tabs

  singer_rank = tmp[rank_index]
  rank = singer_rank.text.gsub /\D/,''
# puts "#{rank.to_i}, #{name}"
  recorder['rank'] = rank.to_i

  similarity_singer = []
  doc.css('div.mw300 ul.picFrm li p a').each do |item|
#   puts "similarity_singer: #{item.text}"
    similarity_singer.push item.text
  end
  recorder['similarity'] = similarity_singer


  doc.css('div.mBodFrm4 ul.songerList li').each do |item|
    attribute,value = item.text.split '：'
#   puts "#{user_attribute[attribute]},#{value}"
    next if user_attribute[attribute].nil?
    recorder[user_attribute[attribute]] = value
  end

  singer_intro = doc.css('div#moreContent p#intro').text
  singer_intro = singer_intro.gsub(/#{name}简介/,'').strip
# puts "singer_intro:#{singer_intro}"
  recorder['intro'] = singer_intro
# puts recorder
  kuwo_singer_coll.insert(recorder)
  id = id + 1
end
