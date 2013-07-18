# encoding: utf-8

require 'rubygems'
require 'adwords_api'
# provides various utility methods
require 'adwords_api/utils'
# TODO log of general activity (currently log only SOAP requests)
# require 'logger'
require 'yaml'
require 'pp'

require 'active_model'
# load only ActiveSupport core extensions
# TODO require only parts that are really needed
require 'active_support/core_ext'

require 'adapi/version'
require 'adapi/config'
require 'adapi/api'
require 'adapi/campaign'
require 'adapi/campaign_criterion'
require 'adapi/campaign_target'
require 'adapi/ad_group'
require 'adapi/ad_group_criterion'
require 'adapi/keyword'
require 'adapi/ad'
require 'adapi/ad/text_ad'
require 'adapi/ad_param'
require 'adapi/constant_data'
require 'adapi/constant_data/language'
require 'adapi/constant_data/country'
require 'adapi/constant_data/province'
require 'adapi/location'
require 'adapi/managed_customer'
require 'adapi/budget_order'
require 'adapi/budget'

# monkeypatch that hardcodes HTTP timeout to 5 minutes
require 'httpi_monkeypatch'

# optionally prettify Savon SOAP log
# PS: slow, should be set to false in production
Savon.configure do |config|
  config.pretty_print_xml = ((Adapi::Config.read[:library][:log_pretty_format] == true) rescue false)
end

HTTPI.adapter = :curb
HTTPI.log = false # supress HTTPI output

module Adapi
  API_VERSION = :v201306
end

if RUBY_VERSION < '1.9'
  puts "WARNING: please use ruby 1.9, adapi gem won't work properly in 1.8 and earlier versions"
end
