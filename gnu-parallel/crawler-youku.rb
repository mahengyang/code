#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'set'

def crawler_tags(url)
  tags = Set.new
  begin
    page = Nokogiri::HTML(open(url))
    info_div = page.css('div#vpofficialtitlev5')
    info_div = page.css('div#vpvideotitlev5') if info_div.nil? or info_div.empty?
    info_div.css('div.base div.base_info div.guide div.crumbs a').each {|item|
      tags.add item.text
    }
    puts tags.to_a.join('-')
  rescue Exception => e
    
  end
end
crawler_tags(ARGV[0])
