# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: corfucrmod 0.1.3 ruby lib
# stub: ext/corfucrmod/extconf.rb

Gem::Specification.new do |s|
  s.name = "corfucrmod"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Edmund Highcock"]
  s.date = "2016-07-22"
  s.description = "A gem to allow coderunner to run the trinity code directly."
  s.email = "edmundhighcock@users.sourceforge.net"
  s.extensions = ["ext/corfucrmod/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "clean.sh",
    "ext/corfucrmod/extconf.rb",
    "ext/corfucrmod/corfucrmod.c",
    "lib/corfucrmod.rb",
    "lib/corfucrmod/optimisation.rb",
    "lib/trinoptcrmod.rb",
    "lib/trinoptcrmod/trinopt.rb",
    "corfucrmod.gemspec"
  ]
  s.homepage = "http://github.com/edmundhighcock/corfucrmod"
  s.licenses = ["GPLv3"]
  s.rubygems_version = "2.2.0"
  s.summary = "A gem to allow coderunner to run the trinity code directly via a C interface."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coderunner>, [">= 0.14.2"])
      s.add_runtime_dependency(%q<text-data-tools>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<gs2crmod>, [">= 0.11.33"])
      s.add_runtime_dependency(%q<trinitycrmod>, [">= 0.7.11"])
      s.add_runtime_dependency(%q<ruby-mpi>, [">= 0.2.0"])
      s.add_runtime_dependency(%q<cheasecrmod>, [">= 0.1.0"])
      s.add_runtime_dependency(%q<tokfile>, [">= 0.0.3"])
      s.add_development_dependency(%q<shoulda>, ["= 3.0.1"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 4"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
    else
      s.add_dependency(%q<coderunner>, [">= 0.14.2"])
      s.add_dependency(%q<text-data-tools>, [">= 1.1.3"])
      s.add_dependency(%q<gs2crmod>, [">= 0.11.33"])
      s.add_dependency(%q<trinitycrmod>, [">= 0.7.11"])
      s.add_dependency(%q<ruby-mpi>, [">= 0.2.0"])
      s.add_dependency(%q<cheasecrmod>, [">= 0.1.0"])
      s.add_dependency(%q<tokfile>, [">= 0.0.3"])
      s.add_dependency(%q<shoulda>, ["= 3.0.1"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["> 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 4"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
    end
  else
    s.add_dependency(%q<coderunner>, [">= 0.14.2"])
    s.add_dependency(%q<text-data-tools>, [">= 1.1.3"])
    s.add_dependency(%q<gs2crmod>, [">= 0.11.33"])
    s.add_dependency(%q<trinitycrmod>, [">= 0.7.11"])
    s.add_dependency(%q<ruby-mpi>, [">= 0.2.0"])
    s.add_dependency(%q<cheasecrmod>, [">= 0.1.0"])
    s.add_dependency(%q<tokfile>, [">= 0.0.3"])
    s.add_dependency(%q<shoulda>, ["= 3.0.1"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["> 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 4"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
  end
end

