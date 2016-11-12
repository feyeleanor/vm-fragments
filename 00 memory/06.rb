#!/usr/bin/env ruby
require "fiddle"

class String
	def to_bin
		"#{self.length.to_bin}#{self}#{alignment_padding}"
	end

	private def alignment_padding
		padding = self.length % Fixnum::SIZE
		if padding > 0
			padding = Fixnum::SIZE - padding
		end
		0.chr * padding
	end

	def self.read_bin(pointer)
		pointer[Fixnum::SIZE, Fixnum.read_bin(pointer)]
	end
end

class Fixnum
	SIZE = 1.size
	PACKING_PATTERN = case SIZE
	when 2 then "s"
	when 4 then "l"
	when 8 then "q"
	end + "!"

	def to_bin
		[self].pack(PACKING_PATTERN)
	end

	def self.read_bin(pointer)
		pointer[0, SIZE].unpack(PACKING_PATTERN).first
	end
end

class Float
	SIZE = Fiddle::ALIGN_DOUBLE
	PACKING_PATTERN = "d"

	def to_bin
		[self].pack(PACKING_PATTERN)
	end

	def self.read_bin(pointer)
		pointer[0, SIZE].unpack(PACKING_PATTERN).first
	end
end

class Array
	def to_bin
		fixnum(length) + collect { |v| Fiddle.format(v) }.join
	end

	def self.read_bin(pointer)
	end
end

class Struct
	def to_bin
	end

	def self.read_bin(pointer)
	end
end

module Fiddle
	class BufferOverflow < IndexError
		attr_reader :address, :request
		def initialize(address, request)
			@address = address
			@request = request
			super("Buffer overflow: #{request} bytes at #{address.inspect}")
		end
	end

	def self.format(value)
		value.respond_to?(:to_bin) ? value.to_bin : Marshal.dump(value)
	end

	def self.padding(str)
		pad = str.length % Fixnum::SIZE
		if pad > 0
			pad = Fixnum::SIZE - pad
		end
		pad
	end

	class Pointer
		NIL = Pointer.new(0)
		SIZE = Fixnum::SIZE
		PACKING_PATTERN = case SIZE
		when 2 then "S"
		when 4 then "L"
		when 8 then "Q"
		end + "!"

		def read(type=Fixnum)
			if type.respond_to?(:read_bin)
				type.read_bin(self)
			else
				Marshal.load(self[SIZE, read])
			end
		end

		def dump
			self[0, size].dump
		end

		def write(value)
			str = Fiddle::format(value)
			pad = Fiddle::padding(str)
			l = pad + str.length
			raise BufferOverflow.new(self, l) if l > size
			self[0, l] = str + 0.chr * pad
			self + l
		end

		def to_bin
			[self].pack(PACKING_PATTERN)
		end

		def self.read_bin(pointer)
			pointer[0, SIZE].unpack(PACKING_PATTERN).first
		end
	end
end


m = Fiddle::Pointer.malloc 64
begin
  m.write(0.chr * 59)
	m.write(0.chr * 60)
	m.write(0.chr * 61)
rescue Fiddle::BufferOverflow => e
	p e.message
end

s = "Hello, Terrible Memory Bank!"
i = 4193
f = 17.00091

m.write(i)
puts "[#{m.read}] - [#{m.read(Fixnum)}] - [#{Fixnum.read_bin(m)}]"
q = m.write(-i)
puts "[#{m.read}] - [#{m.read(Fixnum)}] - [#{Fixnum.read_bin(m)}]"

q.write(s)
puts "[#{q.read(String)}] - [#{String.read_bin(q)}] - [#{m.read}]"
puts "[#{m.dump}]"

r = q.write(s[0, s.length - 1])
puts "[#{q.read(String)}] - [#{String.read_bin(q)}]"

t = r.write(f)
puts "[#{m.read}] - [#{q.read(String)}] - [#{r.read(Float)}] - [#{Float.read_bin(r)}]"

t.write(-f)
puts "[#{m.read}] - [#{q.read(String)}] - [#{r.read(Float)}] - [#{t.read(Float)}] - [#{Float.read_bin(t)}]"