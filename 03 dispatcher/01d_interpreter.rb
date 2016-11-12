#!/usr/bin/env ruby

class VM
	def initialize(*program)
		@program = program
		@s = []
		@pc = 0
	end

	def interpret
		loop do
			print_state
			case read_program
			when :push
				@s.push(read_program)
			when :add
				@s[1] += @s[0]
				@s = @s.drop(1)
			when :print
				puts "#{@s[0]}"
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