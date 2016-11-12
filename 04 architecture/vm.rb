class VM
	BL = [:load, :compile, :interpret] + Object.methods

	def initialize *program
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
				if BL.include?(v.name)
					raise "forbidden method: #{v.name}"
				end
				unless methods.include?(v.name)
					raise "unknown method: #{v.name}"
				end
				v = v.unbind
				v.bind(self)
			when methods.include?(v)
				if BL.include?(v)
					raise "forbidden method: #{v}"
				end
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
end