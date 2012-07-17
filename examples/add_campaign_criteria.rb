# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign_criterion = Adapi::CampaignCriterion.new(
  :campaign_id => $campaign[:id],
  :targets => { #  obsolete, use :criteria instead
    :language => %w{ en cs },

    :location => { 
      :id => 21137
      # :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' }
      # :proximity => { :geo_point => '50.083333,14.366667', :radius => '50 km' }
    },

    # add custom platform criteria
    :platform => [ { :id => 30001} ]
  }
)

$campaign_criterion.create

pp $campaign_criterion.attributes

