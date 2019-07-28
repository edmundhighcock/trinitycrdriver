# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "corfucrmod"
  gem.homepage = "http://github.com/edmundhighcock/corfucrmod"
  gem.license = "GPLv3.0"
  gem.summary = %Q{A gem which implements the CorFu Optimisation Framework.}
  gem.description = %Q{CorFu, the Coderunner/Trinity Fusion Optimisation Framework
    allows the optimisation of fusion performance using first principles
    flux calculations via Trinity.}
  gem.email = "edmundhighcock@users.sourceforge.net"
  gem.authors = ["Edmund Highcock"]
	gem.files.exclude 'test/**/*'
	gem.extensions = %w[ext/corfucrmod/extconf.rb]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "corfucrmod #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

NAME = 'corfucrmod'

require "rake/extensiontask"

Rake::ExtensionTask.new "corfucrmod" do |ext|
	  ext.lib_dir = "lib/corfucrmod"
end
