# encoding: utf-8

require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_campaign')

$campaign = Adapi::Campaign.find_complete($campaign.id)

p "Campaign id: %s" % $campaign[:id]
p "Name: %s" % $campaign[:name]
p "Status: %s" % $campaign[:status]

p "Budget delivery method: %s" % $campaign[:budget][:delivery_method]
p "Budget period: %s" % $campaign[:budget][:period]
# TODO budget.amount

p "Bidding strategy type: %s" % $campaign[:bidding_strategy][:xsi_type]
# TODO bidding_strategy.bid_ceiling

p "Targets:"
$campaign[:targets].each do |target|
  p target[:xsi_type]
  p target
end
