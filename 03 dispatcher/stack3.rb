class EmptyStack
	include Enumerable
	attr_reader :head
	def push item
		Stack.new item
	end

	def pop n = 0
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

	def pop n = 1
		if n == 1
			[head, tail]
		else
			r = []
			h = self
			until n < 1 || h.is_a?(EmptyStack)
				r << h.head
				n -= 1
				h = h.tail
			end
			[r, h]
		end
	end

	def each
		t = self
		until t.is_a?(EmptyStack)
			yield t.head
			t = t.tail
		end
	end
end