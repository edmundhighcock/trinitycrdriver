
class CodeRunner::Trinity::Optimisation
	include GSL::MultiMin
	  # optimisation_spec is a hash of {:code_name => {:variable => [initial_guess, dimension_scale_factor]}}
	  # dimension_scale_factor is just some estimate of the length scale in which the result
	  # varies significantly
	# code_name is either trinity or chease (both can be used simultaneously)
	  attr_reader :optimisation_spec
		attr_reader :optimisation_variables
		attr_accessor :trinity_runner
		def initialize(optimised_quantity, optimisation_spec)
			#@folder = folder
			@optimised_quantity = optimised_quantity
			@optimisation_spec = optimisation_spec
			@optimisation_variables = optimisation_spec.map{|code, hash| hash.map{|var, pars| [code, var]}}.flatten(1)
			@optimisation_starts    = optimisation_spec.map{|code, hash| hash.map{|var, pars| pars[0]}}.flatten(1)
			@optimisation_steps     = optimisation_spec.map{|code, hash| hash.map{|var, pars| pars[1]}}.flatten(1)
			#@runner = CodeRunner.fetch_runner(
			#p ['optimisation_variables', @optimisation_variables]
		end
		def dimension
			@optimisation_variables.size
		end
		def serial_optimise(optimisation_method)
		  MPI.Init
			optimisation_meth = case optimisation_method
													when :simplex
														FMinimizer::NMSIMPLEX
													else 
														raise "Unknown optimisation_method"
													end
			opt = FMinimizer.alloc(optimisation_meth, @optimisation_variables.size)
			func = Proc.new{|v, optimiser| optimiser.func(v)}
			gsl_func = Function.alloc(func, dimension)
			gsl_func.set_params(self)
			opt.set(gsl_func, @optimisation_starts.to_gslv, @optimisation_steps.to_gslv)
			6.times do 
				opt.iterate
				p ['status', opt.x, opt.minimum]
			end

			p 'heellllllo'
			MPI.Finalize
			
		end
		def func(v)
			pars = {}
			pars[:chease] = {}
			pars[:trinity] = {}
			for i in 0...v.size
				code, varname = @optimisation_variables[i]
				val = v[i]
				pars[code][varname] = val
			end
			if not @first_run_done
				pars[:trinity][:ntstep] = 300
				#@first_run_done = true
			#else
				#pars[:trinity][:ntstep] = 100
			end


			trinity_runner.run_class.instance_variable_set(:@mpi_communicator, MPI::Comm::WORLD)
		  if false and trinity_runner.run_list.size > 0
			else
				run = trinity_runner.run_class.new(trinity_runner)
				run.update_submission_parameters(pars[:trinity].inspect)
				#trinity_runner.run_class.instance_variable_set(:@delay_execution, true)
				if trinity_runner.run_list.size > 0
					#run.restart_id = @id
				end
				trinity_runner.submit(run)
				run = trinity_runner.run_list[@id = trinity_runner.max_id]
				run.recheck
				trinity_runner.update
				trinity_runner.print_out(0)
				result =  run.send(@optimised_quantity)
				p ['result is ', result]
				return -result
			end


		  #v.square.sum
		end
end
