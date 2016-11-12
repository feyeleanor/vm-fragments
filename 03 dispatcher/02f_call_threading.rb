#!/usr/bin/env ruby

class VM
	BLACKLIST = [:interpret, :read_program, :dangerous_method] + Object.methods

	def initialize *program
		@s = []
		@pc = 0
		@program = compile(program)
	end

	def compile program
		program.collect do |v|
			case
			when v.is_a?(Method)
				raise "method injection of #{v.name} is not supported"
			when BLACKLIST.include?(v)
				raise "direct execution of #{v} is forbidden"
			when methods.include?(v)
				self.method(v)
			else
				v
			end
		end
	end

	def interpret
		catch :program_complete do
			loop do
				print_state
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

	def dangerous_method
		raise "!!! I'M NOT A VALID OP_CODE !!!"
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