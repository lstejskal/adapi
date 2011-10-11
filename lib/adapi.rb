# encoding: utf-8

require 'rubygems'
require 'adwords_api'
require 'yaml'
require 'pp'

require 'active_model'
# require only ActiveSupport parts that we actually use
require 'active_support/all'

require 'adapi/version'
require 'adapi/config'
require 'adapi/api'
require 'adapi/campaign'
require 'adapi/campaign_target'
require 'adapi/ad_group'
require 'adapi/ad_group_criterion'
require 'adapi/keyword'
require 'adapi/ad'
require 'adapi/ad/text_ad'

# monkeypatch HTTPI
require 'httpi_request_monkeypatch'

HTTPI.adapter = :curb
# supress HTTPI output
# HTTPI.log = false

module Adapi
  API_VERSION = :v201101  
end
