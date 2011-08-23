
require 'adapi'

# create factory for campaign and ad_groups, can be used even in development

campaign_data = {
  :name => "Ataxo Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => { :xsi_type => 'ManualCPC' },
  :budget => {
    :period => 'DAILY',
    :amount => { :micro_amount => 50000000 },
    :delivery_method => 'STANDARD'
  },

  # Set the campaign network options to Search and Search Network.
  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false,
    :target_content_contextual => false
  },

  :ad_groups => [ {
    :name => "Ataxo AdGroup #%d" % (Time.new.to_f * 1000).to_i,
    :status => 'ENABLED',
    :bids => {
      :xsi_type => 'ManualCPCAdGroupBids',
      :keyword_max_cpc => {
        :amount => {
          :micro_amount => 10000000
        }
      }
    }
  } ]

}
 
p Adapi::Campaign.new(:data => campaign_data).create
