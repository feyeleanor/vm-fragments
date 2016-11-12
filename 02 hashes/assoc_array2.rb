require_relative "empty_assoc_array"

class AssocArray
	include Enumerable
	attr_reader :key, :value, :tail

	def initialize k, v, t = nil
		return t if v.nil?
		@tail = t
		@key = k
		@value = v
	end

	def set k, v = nil
		case
		when k.nil?
			self
		when v.nil? && k == self.key
			self.tail
		when v.nil?
			head = node = self
			loop do
				break if node.tail.nil?
				if k == node.key
					node.tail = node.tail.tail
					break
				else
					node = node.tail
				end
			end
			head
		else
			node = self
			loop do
				if node.tail.nil?
					node.tail = AssocArray.new(k, v, node.tail)
					break
				else
					if k == node.key
						node.value = v
						break
					else
						node = node.tail
					end
				end
			end
			self
		end
	end

	def get(k)
		find { |kn, v| kn == k }[1] rescue nil
	end

	def each
		t = self
		until t.nil?
			yield t.key, t.value
			t = t.tail
		end
	end

	protected
	attr_writer :value, :tail
end