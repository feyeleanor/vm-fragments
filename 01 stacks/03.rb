#!/usr/bin/env ruby

class EmptyStack
	include Enumerable
	def push item
		Stack.new item
	end

	def pop
		[nil, self]
	end

	def each
	end
end

class Stack
	include Enumerable
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

	def each
		t = self
		until t.is_a?(EmptyStack)
			yield t.head
			t = t.tail
		end
	end
end

def print_sum stack
	puts "#{stack.count} items: sum = #{stack.reduce(:+)}"
end

s1 = Stack.new(7)
s2 = s1.push(7).push(11)
s1 = s1.push(2).push(9).push(4)
s3 = s1.push(17)
s1 = s1.push(3)

print_sum(s1)
print_sum(s2)
print_sum(s3)