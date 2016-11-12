#!/usr/bin/env ruby
require "fiddle"

class String
  def alignment_pad
    self.length % Fiddle::ALIGN_INT
  end

  def aligned_length
    self.length + self.alignment_pad
  end
end

class Fiddle::Pointer
  def write_int(address, int)
    self[address, Fiddle::SIZEOF_INT] = [int].pack("l")
  end

  def read_int(address)
    self[address, Fiddle::SIZEOF_INT].unpack("l").first
  end

  def write_str(address, str)
    write_int(address, str.length)
    address += Fiddle::SIZEOF_INT
    self[address, str.length] = str
    if (misalign = str.alignment_pad) != 0
      self[address + str.length, misalign] = 0.chr * misalign
    end
  end

  def read_str(address)
    size = read_int(address)
    self[address + Fiddle::SIZEOF_INT, size]
  end

  def write_float(address, float)
    self[address, Fiddle::SIZEOF_DOUBLE] = [float].pack("d")
  end

  def read_float(address)
    self[address, Fiddle::SIZEOF_DOUBLE].unpack("d").first
  end
end

s = "Hello, Terrible Memory Bank!"
i = 4193
f = 17.00091

m = Fiddle::Pointer.malloc 64
m.write_int(0, i)
p m.read_int(0)

m.write_int(0, -i)
p m.read_int(0)

m.write_str(4, s)
p m.read_str(4)

m.write_str(4, s[0, s.length - 1])
p m.read_str(4)

m.write_str(4, s)
p m.read_str(4)

m.write_float(4 + s.aligned_length, f)
p m.read_float(4 + s.aligned_length)

m.write_float(4 + s.aligned_length + 8, -f)
p m.read_float(4 + s.aligned_length + 8)