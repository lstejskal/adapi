
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

p 'original status: %s' % $campaign[:status]

$campaign = Adapi::Campaign.activate(:id => $campaign[:id])

p 'updated status: %s' % $campaign[:status]

$campaign = Adapi::Campaign.delete(:id => $campaign[:id])

p 'updated status (again): %s' % $campaign[:status]
