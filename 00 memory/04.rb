#!/usr/bin/env ruby
require "fiddle"

class String
  def alignment_pad
    Fiddle::ALIGN_INT - (self.length % Fiddle::ALIGN_INT)
  end

  def alignment
    Fiddle::ALIGN_INT + self.length + self.alignment_pad
  end

  def to_bin
  	"#{self.length.to_bin}#{self}#{0.chr * self.alignment_pad}"
  end

  def self.read_bin(pointer)
      size = Fixnum.read_bin(pointer)
	  pointer += Fiddle::SIZEOF_INT
	  pointer[0, size]
  end
end

class Fixnum
  def to_bin
    [self].pack("l")
  end

  def alignment
	Fiddle::ALIGN_INT
  end

  def self.read_bin(pointer)
    pointer[0, Fiddle::SIZEOF_INT].unpack("l").first
  end
end

class Float
  def to_bin
    [self].pack("d")
  end

  def alignment
	Fiddle::ALIGN_DOUBLE
  end

  def self.read_bin(pointer)
    pointer[0, Fiddle::SIZEOF_DOUBLE].unpack("d").first
  end
end

class Fiddle::Pointer
  def write(value)
  	l = value.alignment
    self[0, l] = value.to_bin
	self + l
  end

  def read(type = :Fixnum)
    Object.const_get(type.to_s).read_bin(self)
  end
end

s = "Hello, Terrible Memory Bank!"
i = 4193
f = 17.00091

m = Fiddle::Pointer.malloc 64
m.write(i)
p m.read
p m.read(:Fixnum)
p Fixnum.read_bin(m)


m.write(-i)
p m.read
p m.read(:Fixnum)
p Fixnum.read_bin(m)

q = m + 0.alignment
q.write(s)
p q.read(:String)
p String.read_bin(q)
p m.read

r = q.write(s[0, s.length - 1])
p q.read(:String)
p String.read_bin(q)

t = r.write(f)
p m.read
p q.read(:String)
p r.read(:Float)
p Float.read_bin(r)

t.write(-f)
p m.read
p q.read(:String)
p r.read(:Float)
p t.read(:Float)
p Float.read_bin(t)