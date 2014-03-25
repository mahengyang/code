#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'set'
require 'csv'


class RecsysProbs
  attr_reader:user_item
  attr_reader:item_user
  attr_reader:item_tag
  attr_reader:tag_item
  attr_reader:fp

  def initialize(user_item_file,item_tag_file)
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @user_item, @item_user = generate_map user_item_file
    @item_tag, @tag_item = generate_map item_tag_file
  end

  ## 对于:user,item，或者item,tag，这样的关系，生成user => {item1,...}类型的结构
  def generate_map(file)
    @log.info "生成互关联map"
    left_right = {}
    right_left = {}
    @log.debug "filename: #{file}"
    CSV.foreach(file) do |row|
      @log.debug "#{row}"
      left,right = row
      rights = left_right[left]
      if rights.nil?
        rights = Set.new
      end
      rights.add right
      @log.debug "rights: #{rights.to_a}"
      left_right[left] = rights

      lefts = right_left[right]
      if lefts.nil?
        lefts = Set.new
      end
      lefts.add left
      right_left[right] = lefts 
    end
    [left_right,right_left]
  end

  def algo(lambda)
    @log.info "计算得分"
    @fp = distribute lambda
  end

  ## 计算item的得分
  def distribute(lambda)
    fp_user = {}
    @user_item.each do |user,items|
      @log.debug "#{user} => #{items.to_a}"
      # 先把item的权重分发到user/tag
      user_score = {}
      tag_score = {}
      # items owned by user
      items.each do |item|
        # ========== user p ==========
        @item_user[item].each do |user_p|
          score = user_score[user_p]
          if score.nil?
            score = 0
          end
          user_score[user_p] = score + 1.0 / @item_user[item].size
        end
        @log.debug "user_score: #{user_score}"
        @log.debug "item: #{item} | item_tag: #{item_tag}"

        # =========== tag p ==========
        @item_tag[item].each do |tag|
          @log.debug "tag is: #{tag},tag_score: #{tag_score}"
          score = tag_score[tag]
          if score.nil?
            score = 0
          end
          tag_score[tag] = score + 1.0 / @item_tag[item].size
        end
      end
      @log.debug "tag_score: #{tag_score}"
      # ============= 再把user得到的权重分发给item ============
      item_score_u = {}
      user_score.each do |user_p,score_p|
        @user_item[user_p].each do |item|
          score = item_score_u[item]
          if score.nil?
            score = 0
          end
          item_score_u[item] = score + score_p / @user_item[user_p].size
        end
      end

      # ============= 把tag得到的权重分发给item ==============
      item_score_t = {}
      tag_score.each do |tag, score_p|
        @tag_item[tag].each do |item|
          score = item_score_t[item]
          if score.nil?
            score = 0
          end
          item_score_t[item] = score + score_p / @tag_item[tag].size
        end
      end
      # ======== 合并tag和user分发后的权重 ==========
      item_score = item_score_u.merge(item_score_t){ |key, value1, value2| 
        lambda * value1 + (1 - lambda) * value2
      }
      fp_user[user] = item_score
      @log.info "#{user} => #{items.to_a}"
      @log.debug "item_score_u: #{item_score_u}"
      @log.debug "item_score_t: #{item_score_t}"
      @log.info "final score: #{item_score}"
    end
    fp_user
  end

end #end class


recsys = RecsysProbs.new ARGV[0],ARGV[1]
recsys.algo 0.3
