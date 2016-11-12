#!/usr/bin/env ruby

class VM
	OPCODES = [:push, :add_and_print, :exit]
	attr_reader *OPCODES

	def initialize
		@program = []
		@s = []
		@pc = 0
		OPCODES.each do |op|
			instance_variable_set("@#{op}".to_sym, self.method("op_#{op}"))
			m = instance_variable_get("@#{op}".to_sym)
			puts "#{op} => #{m}"
		end
	end

	def load *p
		@program = p
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

vm = VM.new
vm.load(
	vm.push, 13,
	vm.push, 28,
	vm.add_and_print,
	vm.exit
)
vm.interpret