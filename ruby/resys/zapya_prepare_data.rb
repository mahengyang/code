#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'csv'
require 'mongo'


class RecsysProbs

  def initialize
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    @db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
  end

  def generate_data(user_item,item_tag)
    @log.info "生成文件"
    user_item_file = CSV.open(user_item,'wb')
    item_tag_file = CSV.open(item_tag,'wb')
    @db['sharings.audio'].find().each do |record|
      user = record['zapyaId']
      item = record['n']
      audioId = @db['audioId'].find_one({n:item})
      next if audioId.nil?
      user_item_file << [user, audioId['_id']]
      item_tag_file << [audioId['_id'], audioId['singer']]
    end
  end

end #end class


recsys = RecsysProbs.new
recsys.generate_data '/media/puffin/other/user_item.csv', '/media/puffin/other/item_tag.csv'
