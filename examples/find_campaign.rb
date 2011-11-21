# encoding: utf-8

require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_campaign')

$campaign = Adapi::Campaign.find_complete($campaign.id)

puts "Campaign id: %s" % $campaign[:id]
puts "Name: %s" % $campaign[:name]
puts "Status: %s" % $campaign[:status]

puts "\nBudget delivery method: %s" % $campaign[:budget][:delivery_method]
puts "Budget period: %s" % $campaign[:budget][:period]
# TODO budget.amount

puts "\nBidding strategy type: %s" % $campaign[:bidding_strategy][:xsi_type]
# TODO bidding_strategy.bid_ceiling

puts "\nTargets:"
$campaign[:targets].each do |target|
  p target[:xsi_type]
  p target
end

puts "\nAd groups:"
$campaign[:ad_groups].each do |ad_group|
  puts "\nAd group Id: %s, Name: %s, Status: %s" % [ ad_group[:id], ad_group[:name], ad_group[:status] ]
end
