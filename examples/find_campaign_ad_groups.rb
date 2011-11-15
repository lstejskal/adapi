# encoding: utf-8

require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

# find all ad_groups for campaign
 
$ad_groups = Adapi::AdGroup.find :all, :campaign_id => $campaign.to_param

p "Found %s ad groups." % $ad_groups.size

$ad_groups.each do |ad_group|
  p "ID: %s, NAME %s, STATUS %s" % [ ad_group[:id], ad_group[:name], ad_group[:status] ]
end
