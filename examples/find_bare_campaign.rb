# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign = Adapi::Campaign.find($campaign.id)

puts "Campaign data:"
%w{ id name status serving_status start_date end_date }.each do |param_name|
  puts "  %s: %s" % [ param_name.humanize, $campaign[param_name] ]
end

puts "\nBudget:"
puts "  Delivery method: %s" % $campaign[:budget][:delivery_method]
puts "  Period: %s" % $campaign[:budget][:period]
# TODO budget.amount

# TODO bidding strategy

puts "\nStats:"
%w{ clicks impressions cost ctr }.each do |param_name|
  puts "  %s: %s" % [ param_name.humanize, $campaign[:campaign_stats][param_name.to_sym] ]
end
