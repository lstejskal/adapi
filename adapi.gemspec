# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adapi/version"

Gem::Specification.new do |s|
  s.name        = "adapi"
  s.version     = Adapi::VERSION
  s.authors     = ["Lukas Stejskal"]
  s.email       = ["lucastej@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{User-friendly interface to Google Adwords API}
  s.description = %q{This gem provides user-friendly interface to Google Adwords API.}

  s.rubyforge_project = "adapi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "google-ads-common", "~> 0.5.0"
  s.add_dependency "google-adwords-api", "~> 0.4.0"
  s.add_dependency "activemodel", "~> 3.1"
  s.add_dependency "activesupport", "~> 3.1"
  s.add_dependency "rake", "~> 0.9.2"
  s.add_dependency "curb", "~> 0.7"

  s.add_development_dependency "yard", "~> 0.7"
  s.add_development_dependency "rcov", "~> 0.9"
  s.add_development_dependency "turn", "0.8.2" # PS: 0.8.3 is broken
  s.add_development_dependency "shoulda"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "minitest"
end
