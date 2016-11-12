require_relative "empty_assoc_array"

class AssocArray
	include Enumerable
	attr_reader :key, :value, :tail

	def initialize k, v, t = EmptyAssocArray.new
		raise ArgumentError unless is_assoc_array?(t)
		return t if v.nil?
		@tail = t
		@key = k
		@value = v
	end

	def set k, v = nil
		return self if k.nil?
		if k == key
			v.nil? ? @tail : AssocArray.new(k, v, @tail)
		else
			AssocArray.new(@key, @value, @tail.set(k, v))
		end
	end

	def get(k)
		find { |kn, v| kn == k }[1] rescue nil
	end

	def each
		t = self
		until t.is_a?(EmptyAssocArray)
			yield t.key, t.value
			t = t.tail
		end
	end

	private def is_assoc_array?(x)
		x.is_a?(AssocArray) || x.is_a?(EmptyAssocArray)
	end
end