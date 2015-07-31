CodeRunner.setup_run_class('chease')

class CodeRunner::Chease
  def execute
    system "#{executable}"
  end
end
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
    attr_accessor :parameters_obj
    attr_accessor :results_hash
    def initialize(optimised_quantity, optimisation_spec)
      #@folder = folder
      @optimised_quantity = optimised_quantity
      @optimisation_spec = optimisation_spec
      @optimisation_variables = optimisation_spec.map{|code, hash| hash.map{|var, pars| [code, var]}}.flatten(1)
      @optimisation_starts    = optimisation_spec.map{|code, hash| hash.map{|var, pars| pars[0]}}.flatten(1)
      @optimisation_steps     = optimisation_spec.map{|code, hash| hash.map{|var, pars| pars[1]}}.flatten(1)
      #@runner = CodeRunner.fetch_runner(
      #p ['optimisation_variables', @optimisation_variables]
      @results_hash = {}
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
      @results_hash[:start_time] = Time.now.to_i
      opt = FMinimizer.alloc(optimisation_meth, @optimisation_variables.size)
      @parameters_obj = parameters_obj
      func = Proc.new{|v, optimiser| optimiser.func(v)}
      eputs 'Created func'
      gsl_func = Function.alloc(func, dimension)
      eputs 'Allocated gsl_func'
      gsl_func.set_params(self)
      eputs 'Set params'
      opt.set(gsl_func, @optimisation_starts.to_gslv, @optimisation_steps.to_gslv)
      eputs 'Set func and starting iteration'
      parameters_obj.nit.times do |i|
        opt.iterate
        p ['status', opt.x, opt.minimum, i, parameters_obj.nit]
        @results_hash[:iterations] ||= []
        @results_hash[:iterations].push [opt.x.dup, opt.minimum]
        @results_hash[:elapse_mins] = (Time.now.to_i - @results_hash[:start_time]).to_f/60
        @results_hash[:current_time] = Time.now.to_i
        File.open('results', 'w'){|f| f.puts @results_hash.pretty_inspect}
      end

      p 'heellllllo'
      #MPI.Finalize
      
    end
    def func(v)
      eputs 'Starting func'
      pars = {}
      pars[:chease] = {}
      pars[:trinity] = {}
      for i in 0...v.size
        code, varname = @optimisation_variables[i]
        val = v[i]
        pars[code][varname] = val
      end
      if not @first_run_done
        pars[:trinity][:ntstep] = @parameters_obj.ntstep_first
        pars[:trinity][:nifspppl_initial] = 500
        pars[:trinity][:niter] = 1
      else
        pars[:trinity][:ntstep] = @parameters_obj.ntstep
        pars[:trinity][:nifspppl_initial] = -1
        pars[:trinity][:niter] = 3
      end

      pars[:chease][:ap] = [0.3,0.5,0.4,0.0,0.4,0.0,0.0]
      pars[:chease][:at] = [0.16,1.0,1.0,-1.1,-1.1]


      trinity_runner.run_class.instance_variable_set(:@mpi_communicator, MPI::Comm::WORLD)
      if false and trinity_runner.run_list.size > 0
      else
        if @first_run_done
          #crun.nppfun=4
          #crun.neqdsk=0
          #crun.expeq_file = trinity_runner.run_list[@id]
        end
        if not @replay
          if not @first_run_done and chease_runner.run_list.size > 0
            #This means we are in a restart
            @replay = true
            @nrun = 1
            if @parameters_obj.delete_final_run
              eputs 'Removing final run: ' + trinity_runner.run_list.keys.max.to_s
              trinity_runner.conditions =  'id==' + trinity_runner.run_list.keys.max.to_s
              trinity_runner.destroy no_confirm: true
              chease_runner.conditions =  'id==' + chease_runner.run_list.keys.max.to_s
              chease_runner.destroy no_confirm: true
            end
          else
            @nrun = nil
            @replay = false
          end
        end
        if @replay
          eputs 'Replaying: ' + @nrun.to_s
          run = trinity_runner.run_list[@nrun]
          if not run
            eputs 'Ending replay at ' + @nrun.to_s
            @replay = false
            @id = @cid = @nrun-1
          end
          @nrun += 1
        end
        if not @replay
          crun = chease_runner.run_class.new(chease_runner)
          raise "No gs_defaults strings" unless @parameters_obj.gs_defaults_strings.size > 0
          @parameters_obj.gs_defaults_strings.each{|prc| crun.instance_eval(prc)}
          crun.update_submission_parameters(pars[:chease].inspect, false)

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

          raise "No trinity_defaults_strings" unless @parameters_obj.trinity_defaults_strings.size > 0
          run.instance_variable_set(:@set_flux_defaults_procs, []) unless run.instance_variable_get(:@set_flux_defaults_procs)
          @parameters_obj.trinity_defaults_strings.each{|prc| run.instance_eval(prc)}
          run.update_submission_parameters(pars[:trinity].inspect, false)
          run.gs_folder = crun.directory
          run.evolve_geometry = ".true."
          eputs ['Set gs_folder', run.gs_folder]
          trinity_runner.run_class.instance_variable_set(:@delay_execution, true)
          if trinity_runner.run_list.size > 0
            run.restart_id = @id
          else
          end
          eputs 'Submitting run'
          trinity_runner.submit(run)
          run = trinity_runner.run_list[@id = trinity_runner.max_id]
          comm = MPI::Comm::WORLD
          arr = NArray.int(1)
          arr[0] = 1
          eputs 'Sending message'
          comm.Bcast(arr,0)
          comm.Bcast_string(run.directory)
          comm.Bcast_string(run.run_name)
          eputs 'Running trinity'
          Dir.chdir(run.directory){run.run_trinity(run.run_name+'.trin', comm)}
          eputs 'Rechecking'
          trinity_runner.update
          eputs 'Queue', run.queue_status
          
          trinity_runner.update
        end
        #trinity_runner.print_out(0)
        Dir.chdir(run.directory) do
          run.recheck
          run.status = :Complete
          run.get_global_results
        end
        result =  run.send(@optimised_quantity)
        p ['result is ', result]
        @first_run_done = true
        @results_hash[:func_calls] ||=[]
        @results_hash[:func_calls].push result
        return -result
      end


      #v.square.sum
    end
end
