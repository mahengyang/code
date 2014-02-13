#!/usr/bin/env ruby
# encoding: utf-8

require 'set'

class Resys

  def initialize(file)
    @data = {}
    File.open(file,'r').each{ |row|
      user,share = row.force_encoding(Encoding::UTF_8).split ','
      next if share.nil?
      share.chomp!
      if @data[user].nil?
        @data[user] = Set.new [share]
      else
        @data[user].add share
      end
    }
  end

  def separate(rate)
    @tran = {}
    @test = {}
    @data.each {|k,v|
      next if v.size < 2
      if rand() < rate
        @tran[k] = v
      else
        @test[k] = v
      end
    }
  end

  # calculate similarity
  def similarity(item1,item2)
    tmp = item1 & item2
    tmp.size / ((item1.size * item2.size) ** (1.0/2))
  end

  def matrix(threshold)
    # prepare item
    shares = {}
    @tran_share_size = 0
    @tran.each { |user,values|
      @tran_share_size = @tran_share_size + values.size
      values.each { |share|
        if shares[share].nil?
          shares[share] = Set.new [user]
        else
          shares[share].add user
        end
      }
    }
    @matrix = {}
    keys = shares.keys
    number = keys.size
    # calculate item-item matrix
    for i in 0..number
      t = i + 1
      k1 = keys[i]
      next if k1.nil?
      next if shares[k1].nil?
      next if shares[k1].size < 2

      for j in t..number
        k2 = keys[j]
        next if k2.nil?
        next if shares[k2].size < 2

        sim = similarity shares[k1], shares[k2]
        next if sim < threshold
        #       puts "#{k1} #{k2} = #{sim}"
        if @matrix[k1].nil?
          @matrix[k1] = {k2 => sim}
        else
          @matrix[k1][k2] = sim
        end #if
      end #for
    end #for
    return @matrix
  end #def

  def filter(number)
    matrix = {}
    @matrix.each {|key,values|
      matrix[key] = Set.new
      tmp = values.sort{|a1,a2| a2[1] <=> a1[1] }
      tmp.each_with_index {|a,i| matrix[key].add(a[0]) if i < number}
    }
    @matrix = matrix
    return matrix
  end

  def resys(items)
    resys = Set.new
    items.each { |item|
      next if @matrix[item].nil?
      resys.merge(@matrix[item])
    }
    return resys
  end

  def checkout()
    tran_size = @tran.size
    matrix_size = @matrix.size
    matrix_item_size = 0
    @matrix.each {|k,values|
      matrix_item_size = matrix_item_size + values.length
    }
    hit = 0
    test_size = @test.size
    test_share_size = 0
    @test.each{ |user,values|
      hit = hit + (values & resys(values)).size
      test_share_size = test_share_size + values.size
    }

    puts "训练集大小：#{tran_size}"
    puts "测试集大小：#{test_size}"
    puts "关联矩阵行数：#{matrix_size}"
    puts "关联矩阵推荐共享总数：#{matrix_item_size}"
    puts "平均推荐结果长度：#{(matrix_item_size / (matrix_size * 1.0)).round(2)}"
    puts "训练集共享数：#{@tran_share_size}"
    puts "测试集共享数：#{test_share_size}"
    puts "命中次数：#{hit}"
    puts "命中率：#{(hit / (1.0 * test_share_size)).round(4) * 100}%"
    puts "准确率：#{(hit / (1.0 * @tran_share_size)).round(4) * 100}%"
  end
end

a = Resys.new(ARGV[0])
a.separate(0.8)
m = a.matrix(0.05)
a.filter(5)
a.checkout
