# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: trinitycrdriver 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "trinitycrdriver"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Edmund Highcock"]
  s.date = "2014-06-23"
  s.description = "A gem to allow coderunner to run the trinity code directly."
  s.email = "edmundhighcock@users.sourceforge.net"
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
    "lib/trinitycrdriver.rb",
    "test/helper.rb",
    "test/test_trinitycrdriver.rb"
  ]
  s.homepage = "http://github.com/edmundhighcock/trinitycrdriver"
  s.licenses = ["GPLv3"]
  s.rubygems_version = "2.2.2"
  s.summary = "A gem to allow coderunner to run the trinity code directly via a C interface."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coderunner>, [">= 0.14.2"])
      s.add_runtime_dependency(%q<text-data-tools>, [">= 1.1.3"])
      s.add_runtime_dependency(%q<gs2crmod>, [">= 0.11.33"])
      s.add_runtime_dependency(%q<trinitycrmod>, [">= 0.4.7"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, [">= 2.0.0"])
    else
      s.add_dependency(%q<coderunner>, [">= 0.14.2"])
      s.add_dependency(%q<text-data-tools>, [">= 1.1.3"])
      s.add_dependency(%q<gs2crmod>, [">= 0.11.33"])
      s.add_dependency(%q<trinitycrmod>, [">= 0.4.7"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["> 1.0.0"])
      s.add_dependency(%q<jeweler>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<coderunner>, [">= 0.14.2"])
    s.add_dependency(%q<text-data-tools>, [">= 1.1.3"])
    s.add_dependency(%q<gs2crmod>, [">= 0.11.33"])
    s.add_dependency(%q<trinitycrmod>, [">= 0.4.7"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["> 1.0.0"])
    s.add_dependency(%q<jeweler>, [">= 2.0.0"])
  end
end
