require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

p "ORIGINAL CAMPAIGN:"
pp $campaign.attributes

$campaign = Adapi::Campaign.update(
  :id => $campaign.id,
  :status => 'ACTIVE',
  :name => "UPDATED_#{$campaign[:name]}",
  :bidding_strategy => 'ManualCPC',
  :budget => 75,
  :network_setting => {
    :target_google_search => false,
    :target_search_network => false,
    :target_content_network => true,
    :target_content_contextual => true
    # FIXME returns error which is not trapped:
    # TargetError.CANNOT_TARGET_PARTNER_SEARCH_NETWORK 
    # :target_partner_search_network => true
  }
)

$campaign = Adapi::Campaign.find($campaign.id)

p "UPDATED CAMPAIGN:"
pp $campaign.attributes
