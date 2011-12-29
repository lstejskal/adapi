
require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

p "ORIGINAL STATUS: %s" % $campaign.status

$campaign.activate

p "STATUS UPDATE 1: %s" % $campaign.status

$campaign.delete

p "STATUS UPDATE 2: %s" % $campaign.status
