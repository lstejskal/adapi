require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

p "ORIGINAL CAMPAIGN:"
pp $campaign.attributes

# $updated_campaign = Adapi::Campaign.update(
$campaign.update(
#   :id => $campaign[:id],
  :status => 'ACTIVE',
  :name => "UPDATED_#{$campaign[:name]}",
  # TODO update bidding_strategy, requires special method call
  # :bidding_strategy => 'ManualCPC',
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

p "UPDATED CAMPAIGN:"
pp $campaign.attributes
