#!/usr/bin/env ruby
 
a = %W(A1 A2 A3 A4 A5 A6 A7 A8 A9 T1 A10 A11 A12 A13 T2 A14 A15 A16 A17 A18)
b = %W(B1 B2 B3 B4 B5 T1 B6 B7 B8 B9 B10 T2 B11 B12 B13 B14 B15)

t1_index_a = a.index "T1"
t1_index_b = b.index "T1"
t2_index_a = a.index "T2"
t2_index_b = b.index "T2"

dist1 = (t2_index_a - t1_index_a).abs
dist2 = (t2_index_b - t1_index_b).abs
dist_t1_t2 = [dist1,dist2].min

# puts "a.size: #{a.size}, t1: #{t1_index_a}, t2: #{t2_index_a}"
# puts "b.size: #{b.size}, t1: #{t1_index_b}, t2: #{t2_index_b}"

start_station = ARGV[0]
end_station = ARGV[1]

final_dist = 0

start_index = a.index(start_station)
end_index = a.index(end_station)

### 如果start和end不在同一条线上（异或：相同为false，相异为true）
if start_index.nil? ^ end_index.nil?
	if start_index.nil?
		start_index = end_index
		end_index = b.index(start_index)
	else
		end_index = b.index(end_station)
	end

	## 如果start在A，end在B
	# 计算start_index到A中两个换乘站的距离，取其中最小的
	dist1 = (start_index - t1_index_a).abs
	dist2 = (start_index - t2_index_a).abs
	dist3 = (start_index - a.size).abs
	dist_a = [dist1,dist2,dist3].min

	# 计算end_index到B中两个换乘站的距离，取其中最小的
	dist1 = (end_index - t1_index_b).abs
	dist2 = (end_index - t2_index_b).abs
	dist_b = [dist1,dist2].min

	final_dist = dist_a + dist_b
else   
### 如果start和end在同一条线上
	# 如果都在B上
	if start_index.nil? && end_index.nil?
		start_index = b.index(start_station)
		end_index = b.index(end_station)

		dist1 = (start_index - end_index).abs
		dist2 = dist_t1_t2 + (t1_index_b - start_index).abs + (t2_index_b-end_index).abs
		final_dist = [dist1, dist2].min
	else
	# 如果都在A上
		dist1 = (start_index - end_index).abs
		dist2 = (a.size - dist1).abs
		final_dist = [dist1, dist2].min
	end
	
end

puts "#{start_station}到#{end_station}的距离：#{final_dist}"
