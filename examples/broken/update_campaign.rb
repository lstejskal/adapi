require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

p "ORIGINAL CAMPAIGN:"
pp $campaign.attributes

$updated_campaign = Adapi::Campaign.update(
  :id => $campaign[:id],
  :status => 'ACTIVE',
  :name => "UPDATED_#{$campaign[:name]}",
  :network_setting => {
    :target_google_search => false,
    :target_search_network => false,
    :target_content_network => true,
    :target_content_contextual => true
  }
)

p "UPDATED CAMPAIGN:"
pp $updated_campaign.attributes
