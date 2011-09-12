
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

# TODO we should be able call it from campaign instance, for example:
# $campaign.set_targets(:language => [ 'en' ], ...)

$campaign_target = Adapi::CampaignTarget.new(
  :campaign_id => $campaign[:id],
  :targets => {
    :language => [ 'en' ],
    # :geo => { :country => 'US' },
    # :geo => { :province => 'US-NE' } # PS: czech provinces don't work, it seems
    :geo => { :proximity => {:geo_point => '38.89859,-77.035971', :radius => '10 km'} }
  }
)

$campaign_target.create

p $campaign_target.attributes