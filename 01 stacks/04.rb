#!/usr/bin/env ruby

def print_sum stack
	puts "stack: #{stack}"
	puts "#{stack.count} items: sum = #{stack.reduce(:+)}"
end

s1 = [7]

s2 = s1.dup
s2.push(7).push(11)

s1.push(2).push(9).push(4)

s3 = s1.dup
s3.push(17)

s1.push(3)

print_sum(s1)
print_sum(s2)
print_sum(s3)