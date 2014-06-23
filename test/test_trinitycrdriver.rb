require 'helper'
require 'coderunner'

class TestTrinitycrdriver < Test::Unit::TestCase
	def setup
    @runner = CodeRunner.fetch_runner(Y: 'test/ifspppl', C: 'trinity', X: '/dev/null')
    Dir.chdir('test/ifspppl'){@runner.run_class.use_new_defaults_file("rake_test", "test.trin")}
		system("gunzip test/gs2_42982/pr08_jet_42982_1d.dat.gz -c > test/gs2_42982/pr08_jet_42982_1d.dat")
		system("gunzip test/gs2_42982/pr08_jet_42982_2d.dat.gz -c > test/gs2_42982/pr08_jet_42982_2d.dat")
		FileUtils.rm_r('test/ifspppl/v') if FileTest.exist?('test/ifspppl/v')
	end
	def test_run
    CodeRunner.submit(Y: 'test/ifspppl', T: false, D: 'rake_test', n: '1', X: ENV['TRINITY_EXEC'])
		@runner.update
		CodeRunner.status(Y: 'test/ifspppl')
		require 'trinitycrdriver'
    CodeRunner.submit(Y: 'test/ifspppl', T: false, D: 'rake_test', n: '1', X: ENV['TRINITY_EXEC'])
		CodeRunner.status(Y: 'test/ifspppl')
		#@runner.run_list[1].run_trinity
	end
	def teardown
		#FileUtils.rm_r('test/ifspppl/v')
    FileUtils.rm('test/ifspppl/.code_runner_script_defaults.rb')
    FileUtils.rm('test/ifspppl/.CODE_RUNNER_TEMP_RUN_LIST_CACHE')
    FileUtils.rm('test/gs2_42982/pr08_jet_42982_1d.dat')
    FileUtils.rm('test/gs2_42982/pr08_jet_42982_2d.dat')
    FileUtils.rm(@runner.run_class.rcp.user_defaults_location + '/rake_test_defaults.rb')
    FileUtils.rm('test/ifspppl/rake_test_defaults.rb')

	end
end
