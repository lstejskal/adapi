# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adapi/version"

Gem::Specification.new do |s|
  s.name        = "adapi"
  s.version     = Adapi::VERSION
  s.authors     = ["Lukas Stejskal"]
  s.email       = ["lucastej@gmail.com"]
  s.homepage    = "https://github.com/lstejskal/adapi"
  s.summary     = %q{User-friendly interface to Google Adwords API}
  s.description = %q{This gem provides user-friendly interface to Google Adwords API.}

  s.rubyforge_project = "adapi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Requires google-adwords-api gem, which provides low-level interface to
  # AdWords API, and its dependecy, google-ads-common gem.
  #
  # * versions of both gems should be freezed
  # * ads-common should be required before adwords-api
  #  
  # PS: versions are freezed because both of these gems change a lot and
  # automatic updates through '~>' can (and already did) break something
  #
  s.add_dependency "google-ads-common", "0.6.4"
  s.add_dependency "google-adwords-api", "0.5.3"

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
