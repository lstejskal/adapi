# encoding: utf-8

require 'adapi'

require_relative 'add_bare_ad_group'

$ad_group.delete

$ad_group = Adapi::AdGroup.find(:first, :id => $ad_group.id, :campaign_id => $campaign.id)

puts "AdGroup status is now set to: " + $ad_group.status
