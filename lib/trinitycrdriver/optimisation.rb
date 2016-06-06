CodeRunner.setup_run_class('chease')

class CodeRunner::Chease
  # We hotwire the execute command so that it just
  # runs it instead of doing a batch submission
  def execute
    system "#{executable}"
  end
end
class CodeRunner::Ecom
  # We hotwire the execute command so that it just
  # runs it instead of doing a batch submission
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
  attr_accessor :gs_runner
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
    @first_call = true
    @ifspppl_converged = false
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
    catch(:out_of_time) do 
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
      eputs 'Optimisation complete'
    end
    eputs 'Optimisation ended'
    #MPI.Finalize

  end
  def func(v)
    val = nil
    count = 1
    val_old, repeat = func_actual(v)
    loop do
      val, repeat, trinity_is_converged = func_actual(v)
      if trinity_is_converged # This means that Trinity has reached steady state

        # Now we check if the loop over recalculating the GS equation
        # has converged
        if ((val_old - val)/val).abs < @parameters_obj.convergence
          if @parameters_obj.use_ifspppl_first and not @ifspppl_converged
            @ifspppl_converged = true
          else 
            break
          end
        end
        break if count > @parameters_obj.max_func_evals

        # If geometry is being evolved internally in Trinity, we don't
        # need to run this loop
        break if not repeat
        val_old = val
        #break if not repeat or (not @first_call and count > 1) or count > 4
        count += 1 unless @parameters_obj.use_ifspppl_first and not @ifspppl_converged
      end
    end
    @first_call = false
    return val
  end
  def func_actual(v)
    eputs 'Starting func'
    @id||=1 # Id of the current trinity run which should always be equal to the number of func_actual calls
    repeat = false
    print_pars = {}
    pars = {}
    pars[:gs] = {}
    pars[:trinity] = {}
    pars[:trinity].absorb(@parameters_obj.trinity_pars) if @parameters_obj.trinity_pars
    pars[:gs].absorb(@parameters_obj.gs_pars) if @parameters_obj.gs_pars
    for i in 0...v.size
      code, varname = @optimisation_variables[i]
      val = v[i]
      code = case code
             when :chease, :ecom
               :gs
             else
               :trinity
             end
      pars[code][varname] = val
      print_pars[code] ||={}
      print_pars[code][varname] = val
    end
    if not @first_run_done
      pars[:trinity][:ntstep] = @parameters_obj.ntstep_first
      #pars[:trinity][:nifspppl_initial] = -1
      #pars[:trinity][:niter] = 2

      # The line below assumes that the whole first run is done
      # with ifspppl, in which case we don't want the timestep to get 
      # too large for the gryfx run afterwards.
      #pars[:trinity][:ntdelt_max] = 0.05
      #pars[:trinity][:convergetol] = -1.0
    else
      pars[:trinity][:ntstep] = @parameters_obj.ntstep
      #pars[:trinity][:nifspppl_initial] = -1
      #pars[:trinity][:niter] = 3
      #pars[:trinity][:ntdelt_max] = 10.0
    end
    if @parameters_obj.use_ifspppl_first and not @ifspppl_converged
      pars[:trinity][:nifspppl_initial] = pars[:trinity][:ntstep]
    else
      pars[:trinity][:nifspppl_initial] = -1
    end


    # Must fix this soon!
    if @parameters_obj.gs_code == 'chease'
      #pars[:gs][:ap] = [0.3,0.5,0.4,0.0,0.4,0.0,0.0]
      #pars[:gs][:at] = [0.16,1.0,1.0,-1.1,-1.1]
    end

    trinity_runner.run_class.instance_variable_set(:@mpi_communicator, MPI::Comm::WORLD)
    #if false and trinity_runner.run_list.size > 0
    #else
    if @first_run_done
      #crun.nppfun=4
      #crun.neqdsk=0
      #crun.expeq_file = trinity_runner.run_list[@id]
    end
    if not @replay
      if not @first_run_done and gs_runner.run_list.size > 0
        #This means we are in a restart
        @replay = true
        @nrun = 1
        if @parameters_obj.delete_final_run
          eputs 'Removing final run: ' + trinity_runner.run_list.keys.max.to_s
          trinity_runner.conditions =  'id==' + trinity_runner.run_list.keys.max.to_s
          trinity_runner.destroy no_confirm: true
          gs_runner.conditions =  'id==' + gs_runner.run_list.keys.max.to_s
          gs_runner.destroy no_confirm: true
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
        @id = @gsid = @nrun-1
      else
        @id = @gsid = @nrun
      end
      @nrun += 1
    end
    Hash.phoenix('func_calls.rb') do |hash|
      hash[@id+1] ||={}
      hash[@id+1][:variables] = v.dup
      hash[@id+1][:print_pars] = print_pars
      hash
    end
    #raise "WORK!!"
    eputs "Written parameters"
    if not @replay
      eputs "Not replaying... starting GS and Trinity runs"
      remaining_wall_mins = (
        @parameters_obj.wall_mins - @parameters_obj.wall_mins_margin -
        (Time.now.to_i - @parameters_obj.start_time).to_f / 60.0
      )
      eputs "Remaining wall mins #{remaining_wall_mins}, wall mins #{@parameters_obj.wall_mins}, start time #{@parameters_obj.start_time}, time #{Time.now.to_i}, margin #{@parameters_obj.wall_mins_margin}"
      if remaining_wall_mins < @parameters_obj.wall_mins_margin
        eputs "Run out of time"
        throw(:out_of_time) 
      end 
      eputs "Starting real run, @id = ",@id
      # Create and initialize the gs run
      gsrun = gs_runner.run_class.new(gs_runner)
      raise "No gs_defaults strings" unless @parameters_obj.gs_defaults_strings.size > 0
      @parameters_obj.gs_defaults_strings.each{|prc| gsrun.instance_eval(prc)}
      if gs_runner.run_list.size > 0 
        #gsrun.restart_id = @gsid
        if @parameters_obj.gs_code == 'chease'
          last_converged = @id
          #We need to find the last converged Trinity run to use as the pressure profile.
          until last_converged == 0 or trinity_runner.combined_run_list[last_converged].is_converged?
            eputs "Run #{last_converged} not converged"
            last_converged -= 1
          end
          #unless (@parameters_obj.use_previous_pressure==0 and not @first_trinity_run_completed)
          unless last_converged == 0
            eputs "Using previous pressure profile"
            # We give CHEASE the pressure profile from the previous run.
            pars[:gs][:nppfun] = 4
            pars[:gs][:nfunc] = 4
            #if prid = @parameters_obj.use_previous_pressure and not @first_trinity_run_completed
            # If the last trinity run did not converge we may want to run exactly
            # the same case again, and in particular use the pressure profile from 
            # the previous Trinity  run as input (as an unconverged pressure profile
            # can lead to a wacky GS solution)
            #gsrun.expeq_in=trinity_runner.combined_run_list[prid].directory + '/chease/EXPEQ.NOSURF'
            #else
            gsrun.expeq_in=trinity_runner.combined_run_list[last_converged].directory + '/chease/EXPEQ.NOSURF'
            #end
            # Don't optimise presssure profile.
            pars[:gs][:nblopt] = 0
          end
        end
      end
      gsrun.update_submission_parameters(pars[:gs].inspect, false)

      # Create and initialize the trinity run
      run = trinity_runner.run_class.new(trinity_runner)
      raise "No trinity_defaults_strings" unless @parameters_obj.trinity_defaults_strings.size > 0
      run.instance_variable_set(:@set_flux_defaults_procs, []) unless run.instance_variable_get(:@set_flux_defaults_procs)
      @parameters_obj.trinity_defaults_strings.each{|prc| run.instance_eval(prc)}
      run.update_submission_parameters(pars[:trinity].inspect, false)

      #if @parameters_obj.gs_code == 'chease' and (run.evolve_geometry and run.evolve_geometry.fortran_true?)
      #pars[:gs][:nblopt] = 0
      #end
      gs_runner.submit(gsrun)
      gsrun = gs_runner.run_list[@gsid = gs_runner.max_id]
      gsrun.recheck
      gs_runner.update
      #gs_runner.print_out(0)
      #FileUtils.cp(gsrun.directory + '/ogyropsi.dat', trinity_runner.root_folder + '/.')

      run.gs_folder = gsrun.directory
      while (
        not FileTest.exist? run.gs_folder + '/ogyropsi.dat' or
        File.read(run.gs_folder + '/ogyropsi.dat') =~ /nan/i
      )
        #eputs "GS solver failed: using previous solution"

        gs_runner.conditions = 'id == ' + @gsid.to_s
        gs_runner.destroy(no_confirm: true)
        gs_runner.conditions = nil
        eputs "GS solver failed for #{v.inspect}: returning 10000"
        return [10000, false]
        #run.gs_folder = gs_runner.run_list[@gsid -= 1].directory
      end
      #run.evolve_geometry = ".true."
      eputs ['Set gs_folder', run.gs_folder]
      trinity_runner.run_class.instance_variable_set(:@delay_execution, true)
      if trinity_runner.run_list.size > 0
        run.restart_id = @id
      else
      end
      eputs 'Submitting run'
      run.wall_mins = remaining_wall_mins
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
      @first_trinity_run_completed
    end # if not @replay
    #trinity_runner.print_out(0)
    Dir.chdir(run.directory) do
      run.recheck
      run.status = :Complete
      run.get_global_results
      if (run.evolve_geometry and run.evolve_geometry.fortran_true?)
        repeat = false
      else
        repeat = true
      end
    end
    result =  run.instance_eval(@optimised_quantity)
    p ['result is ', result, 'repeat: ', repeat]
    @first_run_done = true
    @results_hash[:func_calls] ||=[]
    @results_hash[:func_calls].push [print_pars, result]
    Hash.phoenix('func_calls.rb') do |hash|
      hash[@id] ||={}
      hash[@id][:result] = result
      hash[@id][:repeat] = repeat
      hash[@id][:is_converged] = run.is_converged?
      hash
    end
    return [-result, repeat, run.is_converged?]
    #end


    #v.square.sum
  end
end
