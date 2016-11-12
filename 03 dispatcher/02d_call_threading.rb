#!/usr/bin/env ruby

class VM
	OPCODES = [:push, :add_and_print, :exit, :print_state]
	attr_reader *OPCODES

	def initialize *program
		@s = []
		@pc = 0
		@program = program.collect do |v|
			OPCODES.include?(v) ? self.method(v) : v
		end
	end

	def interpret
		catch :program_complete do
			loop do
				print_state
				read_program.call
			end
		end
	rescue Exception => e
		puts e
		return
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

	def print_state
		puts "@pc[#{@pc}] => #{@program[@pc]}, @s[#{@s.collect { |v| v }.join(", ")}]"
	end
end

VM.new(
	:push, 13,
	:push, 28,
	:add_and_print,
	:print_state,
	:exit
).interpret