
class CodeRunner
	#  This is a customised subclass of the CodeRunner::Run  class  which is designed to run the CodeRunner/Trinity optimisation framework
	#
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

		@uses_mpi = true

		@modlet_required = false
		
		@naming_pars = []

		#  Any folders which are a number will contain the results from flux simulations.
		@excluded_sub_folders = ['trinity_runs', 'chease_runs', 'ecom_runs']

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
			new_run.nopt = -1
			new_run.run_name = nil
			new_run.naming_pars = @naming_pars
			new_run.update_submission_parameters(new_run.parameter_hash.inspect, false) if new_run.parameter_hash 
			new_run.naming_pars.delete(:restart_id)
			new_run.generate_run_name
      raise "This function is not complete"
		end	
		#  This is a hook which gets called just before submitting a simulation. It sets up the folder and generates any necessary input files.
		def generate_input_file
				check_parameters
				if @restart_id
					@runner.run_list[@restart_id].restart(self)
				end
		end

		def check_parameters
		end



    def vim_output
      system "vim -Ro #{output_file} #{error_file}"
    end
    alias :vo :vim_output


		# Parameters which follow the Trinity executable, in this case just the input file.
		def parameter_string
			""
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

	end
end

