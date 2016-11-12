#!/usr/bin/env ruby

require_relative "stack"

class VM
	def initialize(*program)
		@program = program
		@s = EmptyStack.new
		@pc = 0
	end

	def interpret
		l = r = 0
		loop do
			print_state l, r
			case read_program
			when :push
				@s = @s.push(read_program)
			when :add
				l, @s = @s.pop
				r, @s = @s.pop
				@s = @s.push(l + r)
			when :print
				puts "#{l} + #{r} = #{@s.head}"
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

	def print_state l, r
		puts "@pc[#{@pc}] => #{@program[@pc]}, l[#{l}], r[#{r}], @s[#{@s.collect { |v| v }.join(", ")}]"
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