#!/usr/bin/env ruby
# encoding: utf-8
require 'logger'
require 'set'
require 'mongo'

class Bipartite

  def initialize(master, threshold)
    @log = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @threshold = threshold
    @master = master
  end

  def distribute_p(origin_scores, hash)
    @log.debug "origin_scores:#{origin_scores}"
    result_scores = {}
    origin_scores.each{|element, score|
      elements = hash[element]
      next if elements.nil?
      score = 1.0 if score.nil?
      @log.debug "elements:#{elements} score:#{score}"
      score_for_element = elements.inject({}) do |result, e| 
        result[e] = score / elements.size if ! yield e
        result
      end
      @log.debug "score_for_element: #{score_for_element}"
      result_scores.merge!(score_for_element){|k, v1, v2| v1 + v2}
      @log.debug "new score:#{result_scores}"
    }
    result_scores
  end


  ## 计算item的得分
  def probs(master_slave, slave_master)
    @log.debug "probs => "
    all_slaves = master_slave[@master]
    @log.debug "elements related with #{@master}: #{all_slaves}"
    # ============ 先把slave的权重分发到master ==============
    master_score = distribute_p(all_slaves, slave_master){|element| element.eql? @master}
    @log.debug "master_score: #{master_score}"

    # ============= 把master得到的权重分发给slave ==============
    slave_score = distribute_p(master_score, master_slave){|element| all_slaves.include? element}
    slave_score.select{ |k,v| v > @threshold }.sort_by{|k,v| -v }.map { |k,v| {k => v.round(4)} }
  end

  def distribute_h(origin_scores, hash, hash2)
    @log.debug "origin_scores:#{origin_scores}"
    result_scores = {}
    origin_scores.each{|element, score|
      elements = hash[element]
      next if elements.nil?
      score = 1.0 if score.nil?
      @log.debug "elements:#{elements} score:#{score}"
      score_for_element = elements.inject({}) do |result, e| 
        result[e] = score if ! yield e
        result
      end
      @log.debug "score_for_element: #{score_for_element}"
      result_scores.merge!(score_for_element){|k, v1, v2| v1 + v2}
      @log.debug "new score:#{result_scores}"
    }
    result_scores = result_scores.map { |element,score| [element, score.to_f / hash2[element].size] }
    Hash[result_scores]
  end

  def heats(master_slave, slave_master)
    @log.debug "heats => "
    all_slaves = master_slave[@master]
    master_score = distribute_h(all_slaves, slave_master, master_slave){|e| e.eql? @master}

    slave_score = distribute_h(master_score, master_slave,slave_master){|e| all_slaves.include? e}
    slave_score.select{ |k,v| v > @threshold }.sort_by{|k,v| -v }.map { |k,v| {k => v.round(4)} }
  end
end #end class
## 示例数据
user_item = {
  'a' => [1,4],
  'b' => [1,2,3,4],
  'c' => [1,3],
  'd' => [3,5]
}
item_user = {
  1 => ['a', 'b', 'c'],
  2 => ['b'],
  3 => ['b', 'c', 'd'],
  4 => ['a', 'b'],
  5 => ['d']
}

master = 'a'
bipartite = Bipartite.new master, 0.001
recommand = bipartite.probs user_item,item_user
puts "===================== #{master} has ====================="
puts "#{user_item[master]}"
puts "===================== Probability Spread recommand ====================="
puts recommand

recommand = bipartite.heats user_item,item_user
puts "===================== Heat Spread recommand ====================="
puts recommand