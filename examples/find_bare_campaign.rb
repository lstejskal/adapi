# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign = Adapi::Campaign.find($campaign.id)

puts "Campaign data:"
%w{ id name status serving_status ad_serving_optimization_status start_date end_date }.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[param_name] ]
end

puts "\nBudget:"
%w{ amount period delivery_method }.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:budget][param_name.to_sym] ]
end

puts "\nBidding strategy:"
%w{ xsi_type bid_ceiling enhanced_cpc_enabled }.each do |param_name|
  next unless $campaign[:bidding_strategy].has_key?(param_name.to_sym)
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:bidding_strategy][param_name.to_sym] ]
end

puts "\nCampaign stats:"
%w{ clicks impressions cost ctr }.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:campaign_stats][param_name.to_sym] ]
end

puts "\nNetwork setting:"
Adapi::Campaign::NETWORK_SETTING_KEYS.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:network_setting][param_name.to_sym] ]
end
