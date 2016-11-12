#!/usr/bin/env ruby

class EmptyStack
	def push item
		Stack.new item
	end

	def pop
		[nil, self]
	end

	def depth
		0
	end
end

class Stack
	attr_reader :head, :tail

	def initialize data, tail = nil
		@head = data
		@tail = tail || EmptyStack.new
	end

	def push item
		Stack.new item, self
	end

	def pop
		[head, tail]
	end

	def depth
		r = 0
		t = self
		until t.is_a?(EmptyStack)
			t = t.tail
			r += 1
		end
		r
	end
end


s = Stack.new(1).push(3)
puts "s.depth = #{s.depth}"

r, t = s.pop
puts "s.depth = #{s.depth}, t.depth = #{t.depth}"
l, t = t.pop
puts "s.depth = #{s.depth}, t.depth = #{t.depth}"
puts "#{l} + #{r} = #{l + r}"

s = EmptyStack.new.push(2).push(4)
r, t = s.pop
l, t = t.pop
puts "s.depth = #{s.depth}, t.depth = #{t.depth}"
puts "#{l} + #{r} = #{l + r}"