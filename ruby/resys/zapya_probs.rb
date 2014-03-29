#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'set'
require 'mongo'

class RecsysProbs
  attr_reader:user_item
  attr_reader:item_user
  attr_reader:item_tag
  attr_reader:tag_item
  attr_reader:tags
  attr_reader:items
  attr_reader:recommand_item

  def initialize(user_id)
    @user = user_id
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @db = Mongo::Connection.new("localhost", 44001).db("zapya_api")
    @source_coll = @db['sharings.app']
    @tags_coll = @db['qing.keywords']
  end

  ## {item1,item2}
  def find_item_by_user(user)
    records = @source_coll.find({zapyaId:user})
    Set.new records.map{ |r| r['n'] }
  end

  ## {user1,user2}
  def find_user_by_item(item)
    @source_coll.find({n:item}).map { |r| r['zapyaId'] }
  end

  ## {tag1,tag2}
  def find_tag_by_item(item)
    tags = @tags_coll.find({app:item}).map { |r| r['dtag'] }
    tags[0]
  end

  ## {item1 => [tag1,tag2], item2 => [tag3,tag4]}
  def find_item_by_tag(tag)
    @tags_coll.find({"dtag" => {"$in" => [tag]} }).map { |r| r['app'] }
  end

  def generat_map
    @items = find_item_by_user(@user)
    @log.info "#{@user} has #{@items.to_a}"

    @item_user = {}
    @item_tag = {}

    @items.each { |item| 
      @item_user[item] = find_user_by_item(item)

      tags = find_tag_by_item(item)
      next if tags.nil? or tags.empty?
      @item_tag[item] = tags
    }

    # @log.debug "item => users"
    # @log.debug @item_user

    @users = []
    @item_user.values.each {|u|
      @users = @users | u
    }
    @log.info "users size : #{@users.size}"
    @user_item = {}
    @users.each { |u|
      @user_item[u] = find_item_by_user(u)
    }

    @tags = []
    @item_tag.values.each {|t|
      @tags = @tags | t
    }
    @log.info "tags size:#{@tags.size} #{@tags}"

    @tag_item = {}
    @tags.each {|t|
      @tag_item[t] = find_item_by_tag(t)
    }
    @log.debug "================"
    @log.debug @tag_item
  end

  ## 计算item的得分
  def distribute(lambda)
    @log.debug "==== #{@items.to_a}"
    # 先把item的权重分发到user/tag
    user_score = {}
    tag_score = {}
    # items owned by user
    @items.each do |item|
      # ========== user p ==========
      tmp_users = @item_user[item]
      if !tmp_users.nil?
        tmp_users.each { |user_p|
          score = user_score[user_p]
          score = 0 if score.nil?
          user_score[user_p] = score + 1.0 / @item_user[item].size
        }
      end
      @log.debug "user_score: #{user_score}"
      @log.debug "item: #{item} | item_tag: #{item_tag}"

      # =========== tag p ==========
      tmp_tags = @item_tag[item]
      if !tmp_tags.nil?
        tmp_tags.each { |tag|
          @log.debug "tag is: #{tag},tag_score: #{tag_score}"
          score = tag_score[tag]
          score = 0 if score.nil?
          tag_score[tag] = score + 1.0 / @item_tag[item].size
        }
      end
    end
    @log.debug "tag_score: #{tag_score}"
    # ============= 再把user得到的权重分发给item ============
    item_score_u = {}
    user_score.each do |user_p,score_p|
      @user_item[user_p].each do |item|
        score = item_score_u[item]
        score = 0 if score.nil?
        next if @items.member? item
        item_score_u[item] = score + score_p / @user_item[user_p].size
      end
    end

    # ============= 把tag得到的权重分发给item ==============
    item_score_t = {}
    tag_score.each do |tag, score_p|
      @tag_item[tag].each do |item|
        score = item_score_t[item]
        score = 0 if score.nil?
        next if @items.member? item
        item_score_t[item] = score + score_p / @tag_item[tag].size
      end
    end
    # ======== 合并tag和user分发后的权重 ==========
    final_score = item_score_u.merge(item_score_t){ |key, value1, value2| 
      lambda * value1 + (1 - lambda) * value2
    }

    @recommand_item = final_score.select{ |k,v| v > 0.005 }.sort_by{|k,v| -v }.map { |k,v| {k => v.round(4)} }
  end
end #end class

user = ARGV[0].to_i
recsys = RecsysProbs.new user
recsys.generat_map
recsys.distribute 0.2
f = File.open("#{user}-probs.rec",'wb')
f.puts "======== #{user} has =========\n #{recsys.items.to_a}"
f.puts "======== tags =========\n#{recsys.tags}"
recommand_item = recsys.recommand_item.join("\n")
f.puts "======== recommand =========\n#{recommand_item}"