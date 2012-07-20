require 'adapi'

# create campaign with criteria
require_relative 'add_campaign'

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
  },

  # deletes all criteria (except :platform) and create these new ones
  :criteria => {
    :language => [ :sk ],
  }
)

unless $campaign.errors.empty?

  puts "ERROR WHEN UPDATING CAMPAIGN #{$campaign.id}:"
  pp $campaign.errors.full_messages

else

  puts "\nUPDATED CAMPAIGN #{$campaign.id}\n"

  $campaign = Adapi::Campaign.find($campaign.id)

  puts "\nCAMPAIGN DATA:"
  pp $campaign.attributes

  $campaign_criteria = Adapi::CampaignCriterion.find( :campaign_id => $campaign.id )

  puts "\nCRITERIA:"
  pp $campaign_criteria

end
