#!/usr/bin/env ruby

class VM
	OPCODES = [:push, :add_and_print, :exit]
	attr_reader *OPCODES

	def initialize *program
		@s = []
		@pc = 0
		OPCODES.each do |op|
			instance_variable_set("@#{op}".to_sym, self.method("op_#{op}"))
		end
		@program = program.collect do |v|
			OPCODES.include?(v) ? instance_variable_get("@#{v}".to_sym) : v
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

	def op_push
		@s.push(read_program)
	end

	def op_add_and_print
		@s[1] += @s[0]
		@s = @s.drop(1)
		puts "#{@s[0]}"
	end

	def op_exit
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
	:exit
).interpret