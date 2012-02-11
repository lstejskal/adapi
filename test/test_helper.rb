# encoding: utf-8

# FIXME for some reason, tests don't return errors, only quietly fail

require 'rubygems'
gem 'minitest'
require 'test/unit'
require 'turn'
require 'shoulda'
require 'fakeweb'
require 'factory_girl'

# always test the latest version of the gem
# TODO make it an option only through ENV variable switch
require File.join(File.dirname(__FILE__), '..', 'lib', 'adapi')

# load factories
Dir[ File.join(File.dirname(__FILE__), 'factories', '*.rb') ].each { |f| require f }

class Test::Unit::TestCase
  FakeWeb.allow_net_connect = false
end
