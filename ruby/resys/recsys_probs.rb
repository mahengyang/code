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
  attr_reader:fp_user
  attr_reader:fp_tag

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
    CSV.foreach(file) do |row|
      left,right = row
      rights = left_right[left]
      if rights.nil?
        rights = Set.new
      end
      rights.add right
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

  def algo
    @log.info "计算得分"
    @fp_user = distribute @user_item, @item_user
    @fp_tag = distribute @tag_item, @item_tag
  end

  ## 计算right的得分
  def distribute(left_right, right_left)
    left_fp = {}
    left_right.each do |left,rights|
      # 先把item的权重分发到user
      left_score = {}
      rights.each do |right|
        right_left[right].each do |left_p|
          score = left_score[left_p]
          if score.nil?
            score = 0
          end
          left_score[left_p] = score + 1.0 / right_left[right].size
        end
      end
      # 再把user得到的权重分发给item
      right_score = {}
      left_score.each do |left_p,score_p|
        left_right[left_p].each do |right|
          score = right_score[right]
          if score.nil?
            score = 0
          end
          right_score[right] = score + score_p / left_right[left_p].size
        end
      end
      left_fp[left] = right_score
      @log.info "#{left} => #{rights.to_a}"
      @log.info "#{right_score}"
    end
    left_fp
  end

end #end class


recsys = RecsysProbs.new ARGV[0],ARGV[1]
recsys.algo