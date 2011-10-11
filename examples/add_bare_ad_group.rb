# encoding: utf-8

require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

# create ad group with basic data only
# this script is used as an include in other scripts

$ad_group_data = {
  :campaign_id => $campaign[:id],
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  # TODO refactor AdGroup.bids DSL
  :bids => {
    # this should be set automatically, it's dependent on Campaign.bids
    :xsi_type => 'BudgetOptimizerAdGroupBids',
    # :keyword_max_cpc => 10
    :proxy_keyword_max_cpc => {
      :amount => {
        :micro_amount => 10000000
      }
    }
  }
}
 
$ad_group = Adapi::AdGroup.create($ad_group_data)


p "Created ad_group ID #{$ad_group.id} for campaign ID #{$ad_group.campaign_id}"
p $ad_group.attributes
