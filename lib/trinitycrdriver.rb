
require 'trinitycrdriver/trinitycrdriver'
require 'mpi'

class CodeRunner::Trinity
	# We overwrite the system module's implemenation of this command.
	# Instead of running trinity via a bash command or a batch script,
	# we run it directly via its API.
	@delay_execution = false
	def execute
		if rcp.delay_execution
			return
		else
			execute_actual
		end
	end
	def execute_actual
		Dir.chdir(@directory){
			if rcp.mpi_communicator?
				start_mpi = false
				mpicomm = rcp.mpi_communicator
			else
				start_mpi = true
				MPI.Init
				mpicomm = MPI::Comm::WORLD
				puts ["INITIALISED MPI", mpicomm.size ]
			end
			run_trinity(@run_name + ".trin", mpicomm)
			if start_mpi
				MPI.Finalize
			end

		}
	end
end
