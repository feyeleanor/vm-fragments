#!/usr/bin/env ruby

class VM
	BLACKLIST = [:load, :compile, :interpret] + Object.methods

	def initialize *program
		@s = []
		load(program)
	end

	def load program
		@program = compile(program)
		self
	end

	def compile program
		program.collect do |v|
			case
			when v.is_a?(Method)
				raise "method injection of #{v.inspect} is not supported" if BLACKLIST.include?(v.name)
				raise "unknown method #{v.inspect}" unless methods.include?(v.name)
				v = v.unbind
				v.bind(self)
			when methods.include?(v)
				raise "direct execution of #{v} is forbidden" if BLACKLIST.include?(v)
				self.method(v)
			else
				v
			end
		end
	end

	def interpret
		catch :program_complete do
			@pc = 0
			loop do
				read_program.call
			end
		end
	end

	def push
		@s.push(read_program)
	end

	def add_and_print
		@s[1] += @s[0]
		@s = @s.drop(1)
		puts "#{@s[0]}"
	end

	def exit
		throw :program_complete
	end

	private def read_program
		r = @program[@pc]
		@pc += 1
		r
	end
end

begin
	VM.new(:dangerous_method)
rescue Exception => e
	puts "program compilation failed: #{e}"
end

vm = VM.new
p = vm.compile([
	:push, 13,
	:push, 28,
	:add_and_print,
	:exit
])

begin
	VM.new(*p)
rescue Exception => e
	puts "program compilation failed: #{e}"
end

vm.load(p).interpret
VM.new(*p).interpret