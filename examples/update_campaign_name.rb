
require 'adapi'

# create campaign
require 'add_bare_campaign'

p 'original name: %s' % $campaign[:name]

$campaign = Adapi::Campaign.rename(
  :id => $campaign[:id],
  :name => "Renamed Campaign #%d" % (Time.new.to_f * 1000).to_i
)

p 'updated name: %s' % $campaign[:name]
