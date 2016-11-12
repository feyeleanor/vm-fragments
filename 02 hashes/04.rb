#!/usr/bin/env ruby

require_relative "assoc_array2"

class Map
	include Enumerable
	def initialize(s)
		@chains = Array.new(s, EmptyAssocArray.new)
	end

	def chain(key)
		key.to_s.to_sym.hash % @chains.length
	end

	def get(key)
		if key.is_a?(String)
			@chains[chain(key)].get(key.to_sym)
		else
			@chains[chain(key)].get(key)
		end
	end

	def set(key, value)
		b = chain(key)
		@chains[b] = @chains[b].set(key.to_s.to_sym, value)
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