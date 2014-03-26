#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'mongo'
require 'celluloid'


class Mapper
  include Celluloid
  include Celluloid::Logger

  def initialize
    @db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
  end

  def map(db_cursor, offset)
    user_item = {}
    item_tag = {}
    info "========= start: #{offset} ========="
    db_cursor.each do |record|
      user = record['zapyaId']
      audio_name = record['n']
      audio = @db['audioId'].find_one({n:audio_name})
      next if audio.nil?
      audio_id = audio['_id']
      audio_singer = audio['singer']
      debug "#{user} #{audio_singer} #{audio_id} #{audio_name}"
      items = user_item[audio_id]
      if items.nil?
        items = Set.new
      end
      items.add audio_id
      user_item[user] = items

      tags = item_tag[audio_id]
      if tags.nil?
        tags = Set.new 
      end
      tags.add audio_singer
      item_tag[audio_id] = tags
    end
    [user_item, item_tag]
  end
end #end class
