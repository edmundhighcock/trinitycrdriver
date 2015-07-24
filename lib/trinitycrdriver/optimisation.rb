
class CodeRunner::Trinity::Optimisation
  include GSL::MultiMin
    # optimisation_spec is a hash of {:code_name => {:variable => [initial_guess, dimension_scale_factor]}}
    # dimension_scale_factor is just some estimate of the length scale in which the result
    # varies significantly
  # code_name is either trinity or chease (both can be used simultaneously)
    attr_reader :optimisation_spec
    attr_reader :optimisation_variables
    attr_accessor :trinity_runner
    attr_accessor :chease_runner
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
    def serial_optimise(optimisation_method, parameters_obj)
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
      parameters_obj.nit.times do |i|
        opt.iterate
        p ['status', opt.x, opt.minimum, i, parameters_obj.nit]
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
      else
        #pars[:trinity].delete(:ntstep)
        pars[:trinity][:ntstep] = 100
      end

      pars[:chease][:ap] = [0.3,0.5,0.4,0.0,0.4,0.0,0.0]
      pars[:chease][:at] = [0.16,1.0,1.0,-1.1,-1.1]


      trinity_runner.run_class.instance_variable_set(:@mpi_communicator, MPI::Comm::WORLD)
      if false and trinity_runner.run_list.size > 0
      else
        crun = chease_runner.run_class.new(chease_runner)
        crun.update_submission_parameters(pars[:chease].inspect)
        if @first_run_done
          #crun.nppfun=4
          #crun.neqdsk=0
          #crun.expeq_file = trinity_runner.run_list[@id]
        end
        if chease_runner.run_list.size > 0
          crun.restart_id = @cid
        end
        chease_runner.submit(crun)
        crun = chease_runner.run_list[@cid = chease_runner.max_id]
        crun.recheck
        chease_runner.update
        #chease_runner.print_out(0)
        #FileUtils.cp(crun.directory + '/ogyropsi.dat', trinity_runner.root_folder + '/.')

        run = trinity_runner.run_class.new(trinity_runner)

        run.update_submission_parameters(pars[:trinity].inspect)
        run.gs_folder = crun.directory
        run.evolve_geometry = ".true."
        #trinity_runner.run_class.instance_variable_set(:@delay_execution, true)
        if trinity_runner.run_list.size > 0
          run.restart_id = @id
        end
        trinity_runner.submit(run)
        run = trinity_runner.run_list[@id = trinity_runner.max_id]
        run.recheck
        trinity_runner.update
        #trinity_runner.print_out(0)
        result =  run.send(@optimised_quantity)
        p ['result is ', result]
        @first_run_done = true
        return -result
      end


      #v.square.sum
    end
end
