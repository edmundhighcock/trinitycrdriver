
require 'trinitycrdriver/trinitycrdriver'
class CodeRunner::Trinity
	# We overwrite the system module's implemenation of this command.
	# Instead of running trinity via a bash command or a batch script,
	# we run it directly via its API.
	def execute
		run_trinity
	end
end
