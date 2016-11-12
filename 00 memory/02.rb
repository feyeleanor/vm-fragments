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
end

class Fixnum
  def to_bin
    [self].pack("l")
  end

  def bin_bytes
	Fiddle::ALIGN_INT
  end
end

class Float
  def to_bin
    [self].pack("d")
  end

  def bin_bytes
	Fiddle::ALIGN_DOUBLE
  end
end

class Fiddle::Pointer
  def write(address, value)
    self[address, value.bin_bytes] = value.to_bin
  end

  def read_int(address)
    self[address, Fiddle::SIZEOF_INT].unpack("l").first
  end

  def read_str(address)
    size = read_int(address)
    self[address + Fiddle::SIZEOF_INT, size]
  end

  def read_float(address)
    self[address, Fiddle::SIZEOF_DOUBLE].unpack("d").first
  end
end

s = "Hello, Terrible Memory Bank!"
i = 4193
f = 17.00091

m = Fiddle::Pointer.malloc 64
m.write(0, i)
p m.read_int(0)

m.write(0, -i)
p m.read_int(0)

m.write(4, s)
p m.read_str(4)

m.write(4, s[0, s.length - 1])
p m.read_str(4)

m.write(4, s)
p m.read_str(4)

m.write(4 + s.bin_bytes, f)
p m.read_float(4 + s.bin_bytes)

m.write(4 + s.bin_bytes + 8, -f)
p m.read_float(4 + s.bin_bytes + 8)