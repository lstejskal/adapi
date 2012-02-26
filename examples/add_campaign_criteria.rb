# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign_criterion = Adapi::CampaignCriterion.new(
  :campaign_id => $campaign[:id],
  :criteria => {
    :language => %w{ en cs },

    :location => {
      # core location types
      :id => 21137,
      # TODO proximity criterion
      # http://code.google.com/apis/adwords/docs/reference/latest/CampaignCriterionService.Proximity.html
      # :proximity => { :geo_point => '50.083333,14.366667', :radius => '50 km' }
      # interpreted location types
      # :country => 'CZ'
      # :province => 'CZ-PR'
      # :city => { :city_name => 'Prague', :province_code => 'CZ-PR', :country_code => 'CZ' }      
    },

    # add custom platform criteria
    :platform => [ { :id => 30001} ]
  }
)

$campaign_criterion.create

p $campaign_criterion.attributes

