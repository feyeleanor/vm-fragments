#!/usr/bin/env ruby
s = []
s.push(1)
s.push(3)
puts "depth = #{s.length}"
l = s.pop
r = s.pop
puts "#{l} + #{r} = #{l + r}"
puts "depth = #{s.length}"