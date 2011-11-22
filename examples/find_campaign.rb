# encoding: utf-8

require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_campaign')

$campaign = Adapi::Campaign.find_complete($campaign.id).to_hash

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

puts "\nAd groups (#{$campaign[:ad_groups].size} in total):"
$campaign[:ad_groups].each do |ad_group|
  puts "ID: %s, NAME %s, STATUS %s" % [ ad_group[:id], ad_group[:name], ad_group[:status] ]
  puts "KEYWORDS: %s" % ad_group[:keywords].join(", ")
  puts "ADS:"
  ad_group[:ads].each do |ad|
    puts "\nheadline: %s" % ad[:headline] 
    puts "description1: %s" % ad[:description1]
    puts "description2: %s" % ad[:description2]
    puts "url: %s" % ad[:url]
    puts "display_url: %s" % ad[:display_url]
  end
end