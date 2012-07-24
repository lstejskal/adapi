# encoding: utf-8

require 'adapi'

require_relative 'add_bare_campaign'

# create ad group with basic data only
# this script is used as an include in other scripts

$ad_group_data = {
  :campaign_id => $campaign[:id],
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :bids => {
    :xsi_type => 'BudgetOptimizerAdGroupBids',
    :proxy_keyword_max_cpc => 15,
    :proxy_site_max_cpc => 30
  }
}
 
$ad_group = Adapi::AdGroup.create($ad_group_data)

unless $ad_group.errors.empty?

  puts "ERROR WHEN CREATING AD GROUP:"
  pp $ad_group.errors.full_messages

else

  puts "\nCREATED AD GROUP #{$ad_group[:id]} FOR CAMPAIGN #{$ad_group[:campaign_id]}\n"
  pp $ad_group.attributes

end
