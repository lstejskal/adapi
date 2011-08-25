
require 'adapi'

# create campaign by single command, with campaing targets, with ad_groups
# including keywords and ads

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

  :targets => {
    :language => [ 'en', 'cz' ],
    :geo => { :province => [ 'CZ-PR', 'CZ-KA' ] }
  },

  :ad_groups => [
    {
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
    }
  ]

}
 
p Adapi::Campaign.new(:data => campaign_data).create
