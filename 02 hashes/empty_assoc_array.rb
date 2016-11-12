class EmptyAssocArray
	include Enumerable
	def set(k, v)
		v.nil? ? self : AssocArray.new(k, v, self)
	end

	def get(k); end
	def each; end
end