#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'json'
require 'csv'
require 'mongo'

mongodb = Mongo::Connection.new("localhost", 44001).db("zapya_api")
kuwo_singer_info = mongodb['kuwo.singerInfo']
kuwo_singer_info.drop()


page_number = 1..1000
CSV.foreach(ARGV[0]) do |row|
  letter,name,singer_url = row
  max_page = 1
  page_number.each do |n|
    params = {
      'name' => name, 
      'type' => 'music',
      'pn' => n,
      'ps' => 25,
      'order' => 'time',
      'contId' => 'artistSong',
      '-' => ''
    }
    resp = Net::HTTP.post_form(URI.parse(singer_url), params)
    doc = Nokogiri::HTML(resp.body)
    if n == 1
      page_item = doc.css('div.pt10 a')
      max_page_item = page_item[page_item.length - 2]
      if max_page_item.nil?
        max_page = 1 
      else
        max_page = max_page_item.text.to_i
      end
    end

    break if n > max_page

    #puts doc 
    doc.css('ul.itemUl li.songName a').each do |item|
      song_url = item['href']
      song_name = item.text
      kuwo_song_coll.insert({name: name, song_url: song_url, song_name: song_name})
    end
  end 
end
