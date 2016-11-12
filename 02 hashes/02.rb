#!/usr/bin/env ruby

require_relative "magnitude"
require_relative "assoc_array2"

class Map
	include Enumerable
	def initialize(s)
		@chains = Array.new(s, EmptyAssocArray.new)
	end

	def chain(key)
		b = 0
		i = key.length() - 1
		while b < Fixnum::MAX && i > -1
			b <<= 8
			b += key[i].ord
			i -= 1
		end
		b % @chains.length
	end

	def get(key)
		@chains[chain(key)].get(key)
	end

	def set(key, value)
		b = chain(key)
		@chains[b] = @chains[b].set(key, value)
	end

	def each
		@chains.each do |c|
			c.each do |k, v|
				yield k, v
			end
		end
	end
end

def print_element map, element
	puts "#{element.inspect} = #{map.get(element)} (count = #{map.count})"
end

m = Map.new(16)
m.set(:apple, "rosy")
print_element(m, "apple")
print_element(m, :apple)

m.set(:blueberry, "sweet")
print_element(m, :blueberry)
print_element(m, :apple)

m.set(:apple, nil)
print_element(m, :apple)

m.set(:cherry, "pie")
print_element(m, :cherry)

m.set("cherry", "tart")
print_element(m, :cherry)
print_element(m, "tart")

m.set(:banana, "green")
print_element(m, :banana)

m.each { |k, v| puts "#{k} => #{v}" }
m.each { |k, v| puts "#{k.inspect} => #{v}" }
m.each_with_index { |(k, v), i| puts "#{i}: #{k.inspect} => #{v}" }