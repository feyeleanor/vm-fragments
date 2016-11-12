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

	def push
		@s.push(read_program)
		read_program.call
	end

	def add_and_print
		lhs = "#{@s[0]} + #{@s[1]}"
		@s[1] += @s[0]
		@s = @s.drop(1)
		puts "#{lhs} = #{@s[0]}"
		read_program.call
	end

	def exit
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
	:print_state,
	:add_and_print,
	:print_state,
	:exit
).interpret