#!/usr/bin/env ruby

require_relative "stack3"

class VM
	def initialize(*program)
		@program = program
		@s = EmptyStack.new
		@pc = 0
	end

	def interpret
		loop do
			print_state
			case read_program
			when :push
				@s = @s.push(read_program)
			when :add
				r, @s = @s.pop(2)
				@s = @s.push(r[0] + r[1])
			when :print
				puts "#{@s.head}"
			when :exit
				return
			else
				puts "#{op.class}"
			end
		end
	rescue Exception => e
		puts e
		return
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

vm = VM.new(
	:push, 13,
	:push, 28,
	:add,
	:print,
	:exit,
)
vm.interpret