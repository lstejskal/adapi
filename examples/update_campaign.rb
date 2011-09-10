
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

p 'original status: %s' % $campaign[:status]

campaign_updates = {
  :id => $campaign[:id],
  :status => 'ACTIVE'
}

$campaign = Adapi::Campaign.update(:data => campaign_updates)

p 'updated status: %s' % $campaign[:status]

$campaign = Adapi::Campaign.update(
  :id => $campaign[:id],
  :data => {:status => 'DELETED'}
)

p 'updated status (again): %s' % $campaign[:status]
