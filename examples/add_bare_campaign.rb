
require 'adapi'

# add campaign with basic data only
# this script is used as an include in other scripts

$campaign_data = {
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  # :bidding_strategy => 'ManualCPC',
  :bidding_strategy => { :xsi_type => 'BudgetOptimizer', :bid_ceiling => 55 },
  :budget => 50,

  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false,
    :target_content_contextual => false
  }
}
 
$campaign = Adapi::Campaign.create($campaign_data)

p $campaign
