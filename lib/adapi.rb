
require 'rubygems'
require 'adwords_api'
require 'collection'
require 'yaml'

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

# load factories
# TODO for development environment only
require 'factory_girl'
Dir[ File.join(File.dirname(__FILE__), '../test/factories/*.rb') ].each { |f| require f }

module Adapi
  API_VERSION = :v201101  
end
