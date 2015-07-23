require 'helper'
require 'coderunner'
require 'mpi'

$ruby_command = "#{RbConfig::CONFIG['bindir']}/#{RbConfig::CONFIG['ruby_install_name']}"

#class TestTrinitycrdriver < Test::Unit::TestCase
  #def setup
    #MPI.Init
    #@mpcomm = MPI::Comm::WORLD
    #for i in 0...@mpcomm.size
      #@runner = CodeRunner.fetch_runner(Y: 'test/ifspppl', C: 'trinity', X: '/dev/null') if @mpcomm.rank==i
      #@mpcomm.Barrier
    #end
    #@runner.run_class.instance_variable_set(:@mpi_communicator, MPI::Comm::WORLD)
    #if @mpcomm.rank == 0
      #Dir.chdir('test/ifspppl'){@runner.run_class.use_new_defaults_file("rake_test", "test.trin")}
      #system("gunzip test/gs2_42982/pr08_jet_42982_1d.dat.gz -c > test/gs2_42982/pr08_jet_42982_1d.dat")
      #system("gunzip test/gs2_42982/pr08_jet_42982_2d.dat.gz -c > test/gs2_42982/pr08_jet_42982_2d.dat")
      #FileUtils.rm_r('test/ifspppl/v') if FileTest.exist?('test/ifspppl/v')
    #end
  #end
  #def test_run
    ##CodeRunner.submit(Y: 'test/ifspppl', T: false, D: 'rake_test', n: '1', X: ENV['TRINITY_EXEC'])
    ##@runner.update
    ##CodeRunner.status(Y: 'test/ifspppl')
    #require 'trinitycrdriver'
    #@runner.run_class.instance_variable_set(:@delay_execution, true)

    #for i in 0...@mpcomm.size
      #CodeRunner.submit(Y: 'test/ifspppl', T: false, D: 'rake_test', n: '1', p: "{ntdelt: #{0.01*(i+1)}}") if @mpcomm.rank == i
      #id = @runner.max_id
      #@mpcomm.Barrier
    #end
    #@runner.run_list[id].execute_actual
    #@runner.run_list[id].recheck
    #@mpcomm.Barrier
    #for i in 0...@mpcomm.size
      #@runner.update if @mpcomm.rank ==i
      #@mpcomm.Barrier
    #end
    #CodeRunner.status(Y: 'test/ifspppl') if @mpcomm.rank == 0
    ##@runner.run_list[1].run_trinity
  #end
  #def teardown
    #if @mpcomm.rank == 0
      #FileUtils.rm_r('test/ifspppl/v')
      #FileUtils.rm('test/ifspppl/.code_runner_script_defaults.rb')
      #FileUtils.rm('test/ifspppl/.CODE_RUNNER_TEMP_RUN_LIST_CACHE')
      #FileUtils.rm('test/gs2_42982/pr08_jet_42982_1d.dat')
      #FileUtils.rm('test/gs2_42982/pr08_jet_42982_2d.dat')
      #FileUtils.rm(@runner.run_class.rcp.user_defaults_location + '/rake_test_defaults.rb')
      #FileUtils.rm('test/ifspppl/rake_test_defaults.rb')
    #end
    #MPI.Finalize

  #end
#end


class TestTrinityOptimisation < Test::Unit::TestCase
  def tfolder
    'test/chease_opt'
  end
  def tfolderchease
    'test/chease_opt_chease'
  end
  def cleanup
    FileUtils.rm(ENV['HOME'] + '/.coderunner/trinitycrmod/defaults_files/rake_test_opt_defaults.rb')
    FileUtils.rm(ENV['HOME'] +'/.coderunner/cheasecrmod/defaults_files/rake_test_opt_chease_defaults.rb') rescue nil
    FileUtils.rm('test/chease_opt/submitting') rescue nil
    FileUtils.rm_r('test/chease_opt/v') rescue nil
    FileUtils.rm_r('test/chease_opt_chease/v') rescue nil
  end
  #def test_chease_opt
    #cleanup
    ##MPI.Init
    #CodeRunner.setup_run_class('trinity')
    #require 'trinitycrdriver'
    #require 'trinitycrdriver/optimisation'
    ##opt = CodeRunner::Trinity::Optimisation.new(:pfus, {trinity: {powerin: [2, 0.5], radin: [0.5, -0.1]}})
    ##opt = CodeRunner::Trinity::Optimisation.new(:pfus, {trinity: {powerin: [2, 0.5]}, chease: {elong: [1.35, 0.2]}})
    ##opt = CodeRunner::Trinity::Optimisation.new(:pfus, {chease: {elong: [1.35, 0.2]}})
    #opt = CodeRunner::Trinity::Optimisation.new(:pfus, {chease: {elong: [1.35, 0.2], triang: [0.0, 0.1]}})
    #@trinity_runner = CodeRunner.fetch_runner(Y: tfolder, X: '/dev/null', C: 'trinity')
    #@trinity_runner.nprocs = '1'
    #@chease_runner = CodeRunner.fetch_runner(Y: tfolderchease, X: '~/Build/chease/trunk/src-f90/chease', C: 'chease')
    #@chease_runner.nprocs = '1'
    #Dir.chdir(tfolder){@trinity_runner.run_class.use_new_defaults_file('rake_test_opt', 'ifspppl_chease_input.trin')}
    #Dir.chdir(tfolderchease){@chease_runner.run_class.use_new_defaults_file('rake_test_opt_chease', 'chease_example.in')}
    ##assert_equal([:trinity, :powerin], opt.optimisation_variables[0])
    #opt.trinity_runner = @trinity_runner
    #opt.chease_runner = @chease_runner
    #opt.serial_optimise(:simplex)
  #end

  def test_trinopt
    trinopt_folder = 'test/trinopt'
    FileUtils.rm(ENV['HOME'] + '/.coderunner/trinitycrmod/defaults_files/trinity_trinopt_defaults.rb') rescue nil
    FileUtils.rm(ENV['HOME'] +'/.coderunner/cheasecrmod/defaults_files/chease_trinopt_defaults.rb') rescue nil
    FileUtils.rm_r(trinopt_folder) if FileTest.exist?(trinopt_folder)
    FileUtils.makedirs(trinopt_folder)
    FileUtils.cp('test/testtrinopt_defaults.rb',ENV['HOME'] + '/.coderunner/trinoptcrmod/defaults_files/testtrinopt_defaults.rb')
    Dir.chdir(trinopt_folder) do
      CodeRunner.code_command('use_new_defaults_file("trinity_trinopt","../chease_opt/ifspppl_chease_input.trin")', C: 'trinity')
      CodeRunner.code_command('use_new_defaults_file("chease_trinopt","../chease_opt_chease/chease_example.in")', C: 'chease')
      CodeRunner.submit(n: '1', C: 'trinopt', D: 'testtrinopt', X: "#$ruby_command", p: "{code_run_environment: %[export RUBYOPT=-I'#{Dir.pwd}/../../lib/']}") 

    end
  end
end
