
require 'adapi'

p Adapi::Config.read[:service][:environment]

# create campaign
require 'add_bare_campaign'

p 'original status: %s' % $campaign[:status]

$campaign = Adapi::Campaign.activate(:id => $campaign[:id])

p 'updated status: %s' % $campaign[:status]

$campaign = Adapi::Campaign.delete(:id => $campaign[:id])

p 'updated status (again): %s' % $campaign[:status]
