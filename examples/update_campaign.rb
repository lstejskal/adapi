require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

p "ORIGINAL CAMPAIGN:"
pp $campaign.attributes

$updated_campaign = Adapi::Campaign.update(
  :id => $campaign[:id],
  :status => 'ACTIVE',
  :name => "UPDATED_#{$campaign[:name]}"
)

p "UPDATED CAMPAIGN:"
pp $updated_campaign.attributes
