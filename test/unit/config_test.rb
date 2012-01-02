# encoding: utf-8
require 'test_helper'

module Adapi
  class ConfigTest < Test::Unit::TestCase
    context "Config params can be overwritten and " do
      def setup
        Adapi::Config.adapi_dir             = 'adapi_dir'
        Adapi::Config.adapi_filename        = 'adapi_filename'
        Adapi::Config.adwords_api_dir       = 'adwords_api_dir'
        Adapi::Config.adwords_api_filename  = 'adwords_api_filename'

        @config = Adapi::Config
      end

      should "correctly set Adapi::Config.adapi_dir" do
        assert_equal 'adapi_dir', @config.adapi_dir
      end

      should "correctly set Adapi::Config.adapi_filename" do
        assert_equal 'adapi_filename', @config.adapi_filename
      end

      should "correctly set Adapi::Config.adwords_api_dir" do
        assert_equal 'adwords_api_dir', @config.adwords_api_dir
      end

      should "correctly set Adapi::Config.adwords_api_file" do
        assert_equal 'adwords_api_filename', @config.adwords_api_filename
      end
    end
  end
end
