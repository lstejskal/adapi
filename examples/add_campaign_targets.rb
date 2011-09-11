
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

# create campaign targets
campaign_target_data = {
  :campaign_id => $campaign[:id],
  :targets => {
    :language => [ 'en' ],
    # :geo => { :country => 'US' },
    # :geo => { :province => 'US-NE' } # czech provinces don't work, it seems
    :geo => { :proximity => {:geo_point => '38.89859,-77.035971', :radius => '10 km'} }
  }
}

p Adapi::CampaignTarget.create(campaign_target_data)
