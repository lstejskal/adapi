
require 'adapi'

# create campaign
require 'add_bare_campaign'

# create campaign targets
campaign_target_data = {
  :campaign_id => $campaign[:id],
  :targets => {
    :language => [ 'en', 'cs' ],
    :geo => { :country => 'CZ' }
  }
}

p Adapi::CampaignTarget.create(campaign_target_data)
