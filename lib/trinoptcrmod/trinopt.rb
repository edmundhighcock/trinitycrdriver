require 'mpi'
class CodeRunner
	#  This is a customised subclass of the CodeRunner::Run  class  which is designed to run the CodeRunner/Trinity optimisation framework
	#
  CodeRunner.setup_run_class('trinity')
  CodeRunner.setup_run_class('chease')
	class Trinopt < Run


		# Where this file is
		@code_module_folder = File.dirname(File.expand_path(__FILE__)) # i.e. the directory this file is in


		################################################
		# Quantities that are read or determined by CodeRunner
		# after the simulation has ended
		###################################################

		@results = [
		]

		@code_long="CodeRunner/Trinity Optimisation Framework"

		@run_info=[:time, :is_a_restart, :restart_id, :restart_run_name, :completed_steps, :percent_complete]

    @variables = [
      :chease_exec,
      :ecom_exec,
      :output,
      :search,
      :trinity_defaults,
      :trinity_defaults_strings,
      :gs_defaults,
      :chease_defaults_strings,
      :ecom_defaults_strings,
      :nit,
      :ntstep_first,
      :ntstep,
      :delete_final_run, 
      :trinity_pars,
      :chease_pars,
      :ecom_pars,
      :gs_code,
      :convergence
    ]
    def gs_defaults_strings
      case @gs_code
      when 'chease'
        @chease_defaults_strings ||= @gs_defaults_strings # For backwards compatibility
      else
        @ecom_defaults_strings
      end
    end
    def gs_defaults_strings=(strs)
      @chease_defaults_strings = strs
    end
    def gs_pars
      case @gs_code
      when 'chease'
        @chease_pars ||= @gs_pars
      when 'ecom'
        @gs_pars
      end
    end

    # For backwards compatibility
    def gs_pars=(pars)
      @chease_pars = pars
    end

		@uses_mpi = true

		@modlet_required = false
		
		@naming_pars = []

		#  Any folders which are a number will contain the results from flux simulations.
		@excluded_sub_folders = ['trinity_runs', 'gs_runs']

    def initialize(*args)
      @trinity_defaults_strings = []
      @chease_defaults_strings = []
      @ecom_defaults_strings = []
      @convergence = 0.05
      super(*args)
    end
		def evaluate_defaults_file(filename)
			text = File.read(filename)
			instance_eval(text)
			text.scan(/^\s*@(\w+)/) do
				var_name = $~[1].to_sym
				next if var_name == :defaults_file_description
				next if var_name == :code_run_environment
				unless rcp.variables.include? var_name or (CodeRunner::Trinity.rcp.variables.include? var_name) or (CodeRunner::Chease.rcp.variables.include? var_name or CodeRunner::Gryfx.rcp.variables.include? var_name or CodeRunner::Gs2.rcp.variables.include? var_name or CodeRunner::Ecom.rcp.variables.include? var_name)
					warning("---#{var_name}---, specified in #{File.expand_path(filename)}, is not a variable. This could be an error")
				end
			end
      eputs '@nstep_is', @nstep
      eputs '@nstep_first', @nstep_first
		end

		#  A hook which gets called when printing the standard run information to the screen using the status command.
		def print_out_line
			#p ['id', id, 'ctd', ctd]
			#p rcp.results.zip(rcp.results.map{|r| send(r)})
			name = @run_name
			name += " (res: #@restart_id)" if @restart_id
			beginning = sprintf("%2d:%d %-60s %1s:%2.1f(%s) %3s%1s",  @id, @job_no, name, @status.to_s[0,1],  @run_time.to_f / 60.0, @nprocs.to_s, percent_complete, "%")
			if ctd
				#beginning += sprintf("Q:%f, Pfusion:%f MW, Ti0:%f keV, Te0:%f keV, n0:%f x10^20", fusionQ, pfus, ti0, te0, ne0)
			end
			beginning += "  ---#{@comment}" if @comment
			beginning
		end



		# Modify new_run so that it becomes a restart of self. Adusts
		# all the parameters of the new run to be equal to the parameters
		# of the run that calls this function, and sets up its run name
		# correctly
		def restart(new_run)
			#new_run = self.dup
			(rcp.variables).each{|v| new_run.set(v, send(v)) if send(v)}
			new_run.is_a_restart = true
			new_run.restart_id = @id
			new_run.restart_run_name = @run_name
			new_run.run_name = nil
			new_run.naming_pars = @naming_pars
			new_run.update_submission_parameters(new_run.parameter_hash.inspect, false) if new_run.parameter_hash 
			new_run.naming_pars.delete(:restart_id)
			new_run.generate_run_name
      raise "trinity_runs directory already exists" if FileTest.exist? new_run.directory + '/trinity_runs'
      FileUtils.ln_s(@directory + '/trinity_runs', new_run.directory + '/trinity_runs')
      FileUtils.ln_s(@directory + '/gs_runs', new_run.directory + '/gs_runs')
		end	
		#  This is a hook which gets called just before submitting a simulation. It sets up the folder and generates any necessary input files.
		def generate_input_file
				check_parameters
				if @restart_id
					@runner.run_list[@restart_id].restart(self)
        else
          FileUtils.makedirs('trinity_runs')
          FileUtils.makedirs('gs_runs')
				end
        File.open("driver_script.rb", "w"){|f| f.puts optimisation_script}
        #FileUtils.ln_s("../../#{@trinity_defaults}_defaults.rb", "trinity_runs")
        #FileUtils.ln_s("../../#{@gs_defaults}_defaults.rb", "gs_runs")
        save
		end

    def optimisation_script
      return <<EOF
      require 'mpi'
      class MPI::Comm
        def Bcast_string(str)
          @arr = NArray.int(1)
          if rank==0
            @arr[0] = str.length
            Bcast(@arr, 0)
            Bcast(str, 0)
          else
            Bcast(@arr,0)
            str << " " while str.length < @arr[0]
            Bcast(str,0)
          end
        end
      end
      puts 'Initializing mpi'
		  MPI.Init
      comm = MPI::Comm::WORLD
      rank = comm.rank
      puts ['Rank is: ', rank]
      if rank==0
        begin
          require 'coderunner'
          CodeRunner.setup_run_class('trinity')
          CodeRunner.setup_run_class('trinopt')
          require 'trinitycrdriver'
          require 'trinitycrdriver/optimisation'
          CodeRunner::Trinopt.run_optimisation(#@id)
        rescue =>err
          arr = NArray.int(1)
          arr[0] = 0
          comm.Bcast(arr,0)
          raise err
        end
        arr = NArray.int(1)
        arr[0] = 0
        comm.Bcast(arr,0)
      else
        require 'trinitycrdriver'
        arr = NArray.int(1)
        puts "Proc \#{comm.rank} waiting for message"
        loop do
          comm.Bcast(arr, 0)
          puts "Proc \#{comm.rank} received instructions: \#{arr[0]}"
          dir = ""
          run_name  = ""
          if arr[0] == 1
            comm.Bcast_string(dir)
            comm.Bcast_string(run_name)
            puts "Proc \#{comm.rank} calling Trinity with run_name: \#{run_name}"
            Dir.chdir(dir){CodeRunner::Trinity.new.run_trinity(run_name+'.trin', comm)}
          else
            break
          end
        end
      end
      MPI.Finalize
EOF
    end

		def check_parameters
		end


    def self.run_optimisation(id = ARGV[-1])
        eputs 'Fetching runner'
        runner = CodeRunner.fetch_runner(Y: '../../', U: true)
        eputs 'Got runner'
        #@run = @runner.run_list[id.to_i]
        run = self.load(Dir.pwd, runner)
        #@run = self.new(nil)
        #@run.instance_eval(File.read('code_runner_info.rb'))
        eputs 'Loaded run'
        #ep @run
        #raise "Can't find run with id #{id}; #{@runner.run_list.keys}" unless @run
        opt = CodeRunner::Trinity::Optimisation.new(
          run.output, run.search
        )
        eputs 'Created opt'
        trinity_runner = CodeRunner.fetch_runner(Y: 'trinity_runs', X: '/dev/null', C: 'trinity')
        trinity_runner.nprocs = MPI::Comm::WORLD.size
        eputs 'Got trinity runner'
        case run.gs_code
        when 'chease'
          gs_runner = CodeRunner.fetch_runner(Y: 'gs_runs', X: run.chease_exec, C: 'chease')
          gs_runner.nprocs = '1'
        when 'ecom'
          gs_runner = CodeRunner.fetch_runner(Y: 'gs_runs', X: run.ecom_exec, C: 'ecom')
          gs_runner.nprocs = '1'
        else
          raise "Unknown gs_code #{run.gs_code.inspect}"
        end
        eputs 'Got gs runner'
        opt.trinity_runner = trinity_runner
        opt.gs_runner = gs_runner
        opt.serial_optimise(:simplex, run)
    end



    def vim_output
      system "vim -Ro #{output_file} #{error_file}"
    end
    alias :vo :vim_output


		# Parameters which follow the Trinity executable, in this case just the input file.
		def parameter_string
			" driver_script.rb #@id"
		end

		def parameter_transition
		end

		def generate_component_runs
			#puts "HERE"
		end

		

		@source_code_subfolders = []

		# This method, as its name suggests, is called whenever CodeRunner is asked to analyse a run directory. This happens if the run status is not :Complete, or if the user has specified recalc_all(-A on the command line) or reprocess_all (-a on the command line).
		#
		def process_directory_code_specific
			get_status
			#p ['id is', id, 'ctd is ', ctd]
			#if ctd
				#get_global_results 
			#end
			#p ['fusionQ is ', fusionQ]
			#@percent_complete = completed_timesteps.to_f / ntstep.to_f * 100.0
      @percent_complete = 0.0
		end

		def get_status
			return :Unknown
		end


		def input_file_extension
			''
		end

    def graphkit(name, options)
      results = eval(File.read(@directory + '/results'))
      case name
      when 'evolution'
        data = {}
        pars_already_listed = []
        results[:func_calls].reverse.each do |pars, res|
          next if pars_already_listed.include? pars
          pars_already_listed.push pars
          pars.each do |code,cpars|
            cpars.each do |vname, val|
              label = "#{code}_#{vname}"
              data[label] ||= []
              data[label].push val
            end
          end
          data['results']||=[]
          data['results'].push res
        end
        kit = GraphKit.quick_create(data.values)
        data.keys.zip(GraphKit::AXES).each{|lbl,ax| kit.set(ax + :label, lbl)}
        kit
      when 'iteration'
        require 'tokfile/ogyropsi'
        step = options[:step_index]
        raise "Please specify step_index" unless step
        iter, _trinstep = trinrunstep(step)[0]
          kit = TokFile::Ogyropsi.new("#@directory/trinity_runs/v/id_#{iter}/chease/ogyropsi#{sprintf("%05d", step)}.dat").summary_graphkit
          kit.gp.multiplot = " layout 3,3 title 'Iteration: #{iter}; Step: #{step}; Pars: #{results[:func_calls][iter-1][0]}; Result: #{results[:func_calls][iter-1][1].inspect}'"
          kit[-1].gp.size = "ratio 1"
          #pp 'kit', kit
        return kit
      end
    end

    def trinstep_mappings
      @trinstep_mappings = (
        trinity_runner = CodeRunner.fetch_runner(Y: @directory + '/trinity_runs')
        sizes = trinity_runner.run_list.values.sort_by{|r| r.id}.map{|r| r.get_completed_timesteps; r.completed_timesteps}
        i = 0; cs = 0
        sizes.inject({}){|h,sz| cs+=sz; h[i+=1]=cs; h}
      )
    end

    def trinrunstep(overall_step)
      p 'trinstep_mappings', trinstep_mappings
      trinrun, cusum = trinstep_mappings.to_a.find{|t, c| c>=overall_step}
      [trinrun, cusum-overall_step + 1]
    end

    def max_step
      trinstep_mappings[-1][1]
    end

	end
end

