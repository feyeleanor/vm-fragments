#!/usr/bin/env ruby
require "fiddle"

class String
  def to_bin
  	"#{self.length.to_bin}#{self}"
  end

  def self.read_bin(pointer)
	  pointer[Fiddle::ALIGN_INT, Fixnum.read_bin(pointer)]
  end
end

class Fixnum
  def to_bin
    [self].pack("l")
  end

  def self.read_bin(pointer)
    pointer[0, Fiddle::ALIGN_INT].unpack("l").first
  end
end

class Float
  def to_bin
    [self].pack("d")
  end

  def self.read_bin(pointer)
    pointer[0, Fiddle::ALIGN_DOUBLE].unpack("d").first
  end
end

class Fiddle::BufferOverflow < IndexError
	attr_reader :address, :request
  def initialize(address, request)
    @address = address
    @request = request
    super("Buffer overflow: requested #{request} bytes at #{address.inspect}")
  end
end

class Fiddle::Pointer
  def write(value)
	  v = value.to_bin
    if (padding = v.length % Fiddle::ALIGN_INT) > 0
      padding = Fiddle::ALIGN_INT - padding
      v += 0.chr * padding
    end
    l = v.length
	  raise Fiddle::BufferOverflow.new(self, l) if l > size
    self[0, l] = v
	  self + l
  end

  def read(type = :Fixnum)
    Object.const_get(type.to_s).read_bin(self)
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
puts "#{m.read}, #{m.read(:Fixnum)}, #{Fixnum.read_bin(m)}"

q = m.write(-i)
puts "#{m.read}, #{m.read(:Fixnum)}, #{Fixnum.read_bin(m)}"

q.write(s)
puts "#{q.read(:String)}, #{String.read_bin(q)}, #{m.read}"

r = q.write(s[0, s.length - 1])
puts "#{q.read(:String)}, #{String.read_bin(q)}"

t = r.write(f)
puts "#{m.read}, #{q.read(:String)}, #{r.read(:Float)}, #{Float.read_bin(r)}"

t.write(-f)
puts "#{m.read}, #{q.read(:String)}, #{r.read(:Float)}, #{p t.read(:Float)}, #{Float.read_bin(t)}"