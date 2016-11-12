#!/usr/bin/env ruby

require_relative "vm"

class Adder < VM
	def interpret
		@r = Array.new(2, 0)
		super
	end

	def load_value
		@r[read_program] = read_program
		read_program.call
	end

	def add
		@r[read_program] += @r[read_program]
		read_program.call
	end

	def jump_if_not_zero
		if @r[read_program] == 0
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
		puts "#{@pc}: @r => #{@r}"
	end
end

Adder.new(
	:load_value, 0, 13,
	:load_value, 1, -1,
	:print_state,
	:add, 0, 1,
	:print_state,
	:jump_if_not_zero, 0, 7,
	:read_program,
	:print_state,
	:exit
).interpret