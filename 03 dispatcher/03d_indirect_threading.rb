#!/usr/bin/env ruby

class VM
	BLACKLIST = [:load, :compile, :interpret] + Object.methods

	def initialize *program
		@s = []
		m = methods
		load(program)
	end

	def load program
		@program = compile(program)
		self
	end

	def compile program
		program.collect do |v|
			case
			when v.is_a?(Method)
				raise "method injection of #{v.inspect} is not supported" if BLACKLIST.include?(v.name)
				raise "unknown method #{v.inspect}" unless methods.include?(v.name)
				v = v.unbind
				v.bind(self)
			when methods.include?(v)
				raise "direct execution of #{v} is forbidden" if BLACKLIST.include?(v)
				self.method(v)
			else
				v
			end
		end
	end

	def interpret
		catch :program_complete do
			@pc = 0
			loop do
				read_program.call
			end
		end
	end

	def read_program
		r = @program[@pc]
		@pc += 1
		r
	end

	def self.primitive name, body
		class_eval <<-BODY
			def #{name}
				#{body}
				read_program.call
			end
		BODY
	end
end

class Adder < VM
	primitive :push, <<-BODY
		@s.push(read_program)
	BODY

	primitive :add, <<-BODY
		@s[1] += @s[0]
		@s = @s.drop(1)
	BODY

	primitive :jump_if_not_zero, <<-BODY
		if @s[0] == 0
			@pc += 1
		else
			@pc = @program[@pc]
		end
	BODY

	primitive :exit, <<-BODY
		throw :program_complete
	BODY

	primitive :print_state, <<-BODY
		puts \"@pc[\#{@pc}] => \#{@program[@pc]}, @s[\#{@s.collect { |v| v }.join(\", \")}]\"
	BODY
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
