#!/usr/bin/env ruby

require_relative "vm"

class Adder < VM
	def interpret
		@s = []
		super
	end

	def push
		@s.push(read_program)
		read_program.call
	end

	def add
		@s[1] += @s[0]
		@s = @s.drop(1)
		read_program.call
	end

	def jump_if_not_zero
		if @s[0] == 0
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
		puts "#{@pc}: @s => #{@s}"
	end
end

Adder.new(
	:push, 13,
	:push, -1,
	:add,
	:print_state,
	:read_program,
	:print_state,
	:jump_if_not_zero, 2,
	:exit
).interpret