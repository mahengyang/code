#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'set'
require 'mongo'
require './bipartite'

class RecsysProbs
  attr_reader:item_tag
  attr_reader:tag_item
  attr_reader:tags
  attr_reader:items
  attr_reader:heats_recommand_item
  attr_reader:probs_recommand_item

  def initialize(item_name)
    @item_name = item_name
    @bipartite =Bipartite.new @item_name, 0.005
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
    @tags_coll = @db['qing.keywords']
  end

  ## {tag1,tag2}
  def find_tag_by_item(item)
    tags = @tags_coll.find({app:item}).map { |r| r['dtag'] }
    tags[0]
  end

  ## [item1,item2]
  def find_item_by_tag(tag)
    @tags_coll.find({"dtag" => {"$in" => [tag]} }).map { |r| r['app'] }
  end

  def generat_map
    # items has tags
    @tags = find_tag_by_item @item_name
    @tag_item = @tags.inject({}) {|result, t|
      result[t] = find_item_by_tag(t)
      result
    }
    
    @items = @tag_item.values.inject([]) {|result, i|
      result = result | i
      result
    }
    @log.debug "items size:#{@items.size} #{@tags}"
    @item_tag = @items.inject({}){|result, i|
      result[i] = find_tag_by_item i
      result
    }
  end

  def probs_recomand
    @probs_recommand_item = @bipartite.probs @item_tag, @tag_item
  end

  def heats_recomand
    @heats_recommand_item = @bipartite.probs @item_tag, @tag_item
  end
end #end class

item_name = ARGV[0]
recsys = RecsysProbs.new item_name
recsys.generat_map
recsys.probs_recomand
recsys.heats_recomand

puts "======== #{item_name} has =========\n #{recsys.tags.to_a}"
probs_recommand_item = recsys.probs_recommand_item.join("\n")
heats_recommand_item = recsys.heats_recommand_item.join("\n")
puts "======== probs recommand =========\n#{probs_recommand_item}"
puts "======== heats recommand =========\n#{heats_recommand_item}"