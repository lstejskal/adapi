
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

# TODO we should be able call it from campaign instance, for example:
# $campaign.set_targets(:language => [ 'en' ], ...)

$campaign_target = Adapi::CampaignTarget.new(
  :campaign_id => $campaign[:id],
  :targets => {
    :language => [ 'en' ],
    :geo => {
      # :country => 'CZ'
      # :province => 'CZ-PR'
      # :city => { :city_name => 'Prague', :province_code => 'CZ-PR', :country_code => 'CZ' }
      :proximity => { :geo_point => '50.083333,14.366667', :radius => '50 km' }
    }
  }
)

$campaign_target.create

p $campaign_target.attributes