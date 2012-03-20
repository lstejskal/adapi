# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_campaign_criteria'

$criteria = Adapi::CampaignCriterion.find(:campaign_id => $campaign.to_param)

puts "Found %d criteria:\n" % $criteria.size

$criteria.each { |criterion| p criterion }
