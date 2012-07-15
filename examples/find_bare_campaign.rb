# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign = Adapi::Campaign.find($campaign.id)

puts "Campaign data:"
%w{ id name status serving_status start_date end_date }.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[param_name] ]
end

puts "\nBudget:"
%w{ delivery_method period }.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:budget][param_name.to_sym] ]
end
# TODO budget.amount

# TODO bidding strategy

puts "\nStats:"
%w{ clicks impressions cost ctr }.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:campaign_stats][param_name.to_sym] ]
end

puts "\nNetwork setting:"
Adapi::Campaign::NETWORK_SETTING_KEYS.each do |param_name|
  puts "  %s: %s" % [ param_name.to_s.humanize, $campaign[:network_setting][param_name.to_sym] ]
end
