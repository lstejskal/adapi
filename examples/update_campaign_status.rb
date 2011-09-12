
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

p "ORIGINAL STATUS: %s" % $campaign.status

$campaign.activate

p "STATUS UPDATE 1: %s" % $campaign.status

$campaign.delete

p "STATUS UPDATE 2: %s" % $campaign.status
