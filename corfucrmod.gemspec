# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: corfucrmod 1.0.1 ruby lib
# stub: ext/corfucrmod/extconf.rb

Gem::Specification.new do |s|
  s.name = "corfucrmod".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Edmund Highcock".freeze]
  s.date = "2019-07-29"
  s.description = "CorFu, the Coderunner/Trinity Fusion Optimisation Framework\n    allows the optimisation of fusion performance using first principles\n    flux calculations via Trinity.".freeze
  s.email = "edmundhighcock@users.sourceforge.net".freeze
  s.extensions = ["ext/corfucrmod/extconf.rb".freeze]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc",
    "README.rdoc.orig"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "clean.sh",
    "corfucrmod.gemspec",
    "ext/corfucrmod/extconf.rb",
    "ext/corfucrmod/trinitycrdriver_ext.c",
    "lib/corfucrmod.rb",
    "lib/corfucrmod/corfu.rb",
    "lib/corfucrmod/optimisation.rb",
    "lib/corfucrmod/trinitycrdriver.rb"
  ]
  s.homepage = "http://github.com/edmundhighcock/corfucrmod".freeze
  s.licenses = ["GPLv3.0".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "A gem which implements the CorFu Optimisation Framework.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coderunner>.freeze, [">= 0.14.2"])
      s.add_runtime_dependency(%q<text-data-tools>.freeze, [">= 1.1.3"])
      s.add_runtime_dependency(%q<gs2crmod>.freeze, [">= 0.11.33"])
      s.add_runtime_dependency(%q<trinitycrmod>.freeze, [">= 0.7.11"])
      s.add_runtime_dependency(%q<ruby-mpi>.freeze, [">= 0.2.0"])
      s.add_runtime_dependency(%q<cheasecrmod>.freeze, [">= 0.1.0"])
      s.add_runtime_dependency(%q<tokfile>.freeze, [">= 0.0.3"])
      s.add_development_dependency(%q<shoulda>.freeze, ["= 3.0.1"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>.freeze, ["> 1.0.0"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 2.0.1"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 4"])
      s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<coderunner>.freeze, [">= 0.14.2"])
      s.add_dependency(%q<text-data-tools>.freeze, [">= 1.1.3"])
      s.add_dependency(%q<gs2crmod>.freeze, [">= 0.11.33"])
      s.add_dependency(%q<trinitycrmod>.freeze, [">= 0.7.11"])
      s.add_dependency(%q<ruby-mpi>.freeze, [">= 0.2.0"])
      s.add_dependency(%q<cheasecrmod>.freeze, [">= 0.1.0"])
      s.add_dependency(%q<tokfile>.freeze, [">= 0.0.3"])
      s.add_dependency(%q<shoulda>.freeze, ["= 3.0.1"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_dependency(%q<bundler>.freeze, ["> 1.0.0"])
      s.add_dependency(%q<jeweler>.freeze, [">= 2.0.1"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 4"])
      s.add_dependency(%q<rake-compiler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<coderunner>.freeze, [">= 0.14.2"])
    s.add_dependency(%q<text-data-tools>.freeze, [">= 1.1.3"])
    s.add_dependency(%q<gs2crmod>.freeze, [">= 0.11.33"])
    s.add_dependency(%q<trinitycrmod>.freeze, [">= 0.7.11"])
    s.add_dependency(%q<ruby-mpi>.freeze, [">= 0.2.0"])
    s.add_dependency(%q<cheasecrmod>.freeze, [">= 0.1.0"])
    s.add_dependency(%q<tokfile>.freeze, [">= 0.0.3"])
    s.add_dependency(%q<shoulda>.freeze, ["= 3.0.1"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
    s.add_dependency(%q<bundler>.freeze, ["> 1.0.0"])
    s.add_dependency(%q<jeweler>.freeze, [">= 2.0.1"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 4"])
    s.add_dependency(%q<rake-compiler>.freeze, [">= 0"])
  end
end

