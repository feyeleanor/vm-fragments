#!/usr/bin/env ruby
require "fiddle"

class String
  def alignment_pad
    Fiddle::ALIGN_INT - (self.length % Fiddle::ALIGN_INT)
  end

  def bin_bytes
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

  def bin_bytes
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

  def bin_bytes
	Fiddle::ALIGN_DOUBLE
  end

  def self.read_bin(pointer)
    pointer[0, Fiddle::SIZEOF_DOUBLE].unpack("d").first
  end
end

class Fiddle::Pointer
  def write(address, value)
    self[address, value.bin_bytes] = value.to_bin
  end

  def read(address, type = :Fixnum)
    Object.const_get(type.to_s).read_bin(self + address)
  end
end

s = "Hello, Terrible Memory Bank!"
i = 4193
f = 17.00091

m = Fiddle::Pointer.malloc 64
m.write(0, i)
p m.read(0)
p m.read(0, :Fixnum)
p Fixnum.read_bin(m)


m.write(0, -i)
p m.read(0)
p m.read(0, :Fixnum)
p Fixnum.read_bin(m)

m.write(4, s)
p m.read(4, :String)
p String.read_bin(m + 4)

m.write(4, s[0, s.length - 1])
p m.read(4, :String)
p String.read_bin(m + 4)

m.write(4, s)
p m.read(4, :String)
p String.read_bin(m + 4)

m.write(4 + s.bin_bytes, f)
p m.read(4 + s.bin_bytes, :Float)
p Float.read_bin(m + 4 + s.bin_bytes)

m.write(4 + s.bin_bytes + 8, -f)
p m.read(4 + s.bin_bytes + 8, :Float)
p Float.read_bin(m + 4 + s.bin_bytes + 8)