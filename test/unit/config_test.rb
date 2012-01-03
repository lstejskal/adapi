# encoding: utf-8
require 'test_helper'

module Adapi
  class ConfigTest < Test::Unit::TestCase
    context "Loading adapi.yml" do
      should "load the configuration" do
        # because it could have been set in another test
        # set default values
        Adapi::Config.dir             = 'test/config'
        Adapi::Config.filename        = 'adapi.yml.template'
        @settings                     = Adapi::Config.settings(true)

        assert_equal '555-666-7777', @settings[:default][:authentication][:client_customer_id]
        assert_equal 'adapi_yml@example.com', @settings[:default][:authentication][:email]
        assert_equal 'sandbox_email@example.com', @settings[:sandbox][:authentication][:email]
      end
    end

    context "Loading adwords_api.yml" do
      should "loads the configuration" do
        # because it could have been set in another test
        # set default values
        Adapi::Config.dir             = 'test/config'
        Adapi::Config.filename        = 'adwords_api.yml.template'
        @settings                     = Adapi::Config.settings(true)

        assert_equal '555-666-7777', @settings[:default][:authentication][:client_customer_id]
        assert_equal 'adwords_api_yml@example.com', @settings[:default][:authentication][:email]
        assert_nil @settings[:sandbox]
      end
    end


    context "Config params can be overwritten and " do
      should "correctly set Adapi::Config.adapi_dir" do
        Adapi::Config.dir             = 'adapi_dir'
        assert_equal 'adapi_dir', Adapi::Config.dir
      end

      should "correctly set Adapi::Config.adapi_filename" do
        Adapi::Config.filename        = 'adapi_filename'
        assert_equal 'adapi_filename', Adapi::Config.filename
      end
    end
  end
end
