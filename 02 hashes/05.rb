#!/usr/bin/env ruby

def print_element map, element
	puts "#{element.inspect} = #{map[element]} (count = #{map.count})"
end

m = {}
m[:apple] = "rosy"
print_element(m, "apple")
print_element(m, :apple)

m[:blueberry] = "sweet"
print_element(m, :blueberry)
print_element(m, :apple)

m[:apple] = nil
print_element(m, :apple)

m[:cherry] = "pie"
print_element(m, :cherry)

m["cherry"] = "tart"
print_element(m, :cherry)
print_element(m, "tart")

m[:banana] = "green"
print_element(m, :banana)

m.each { |k, v| puts "#{k} => #{v}" }
m.each { |k, v| puts "#{k.inspect} => #{v}" }
m.each_with_index { |(k, v), i| puts "#{i}: #{k.inspect} => #{v}" }