
require 'adapi'

campaign_id = '334301'

ad_group_data = {
  :name => "Ataxo AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :campaign_id => campaign_id,
  :bids => {
    :xsi_type => 'ManualCPCAdGroupBids',
    :keyword_max_cpc => {
      :amount => {
        :micro_amount => 10000000
      }
    }
  }
}
 
$response = Adapi::AdGroup.new(:data => ad_group_data)

p $response
