#!/usr/bin/env ruby

class VM
	def initialize
		@program = []
		@s = []
		@pc = 0
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
	vm.method(:op_push), 13,
	vm.method(:op_push), 28,
	vm.method(:op_add_and_print),
	vm.method(:op_exit)
)
vm.interpret