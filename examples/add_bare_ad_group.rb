
require 'adapi'

# create campaign
require 'add_bare_campaign'

# create ad group with basic data only
# this script is used as an include in other scripts

$ad_group_data = {
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :campaign_id => $campaign[:id],
  :bids => {
    :xsi_type => 'ManualCPCAdGroupBids',
    :keyword_max_cpc => {
      :amount => {
        :micro_amount => 10000000
      }
    }
  }
}
 
$ad_group = Adapi::AdGroup.create(:data => $ad_group_data)

p $ad_group
