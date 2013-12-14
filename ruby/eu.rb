m = ARGV[0].to_i
n = ARGV[1].to_i
m,n = n,m if m < n

r = m % n
while r != 0
	puts "m=#{m} n=#{n} r=#{r}"
	m,n = n,r
	m,n = n,m if m < n
	r = m % n
end
puts "result = #{n}"