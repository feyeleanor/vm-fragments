#!/usr/bin/env ruby

require_relative "vm"

class Adder < VM
	def interpret
		@s = []
		@a = 0
		super
	end

	def clear
		@a = 0
		read_program.call
	end

	def push_value
		@s.push(read_program)
		read_program.call
	end

	def push
		@s.push(@accum)
		read_program.call
	end

	def add
		@a += @s.pop
		read_program.call
	end

	def jump_if_not_zero
		if @a == 0
			@pc += 1
		else
			@pc = @program[@pc]
		end
		read_program.call
	end

	def exit
		throw :program_complete
	end

	def print_state
		puts "#{@pc}: @a = #{@a}, @s => #{@s}"
	end
end

Adder.new(
	:clear,
	:push_value, 13,
	:print_state,
	:add,
	:print_state,
	:push_value, -1,
	:print_state,
	:add,
	:print_state,
	:read_program,
	:print_state,
	:jump_if_not_zero, 6,
	:exit
).interpret