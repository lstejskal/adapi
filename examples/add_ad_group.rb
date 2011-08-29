
require 'adapi'

# create campaign first

campaign_data = {
  :name => "Ataxo Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => {
    :xsi_type => 'ManualCPC'
  },
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
  }
}

campaign = Adapi::Campaign.new(:data => campaign_data).create

# create ad group

ad_group_data = {
  :name => "Ataxo AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :campaign_id => campaign[:id],
  :bids => {
    :xsi_type => 'ManualCPCAdGroupBids',
    :keyword_max_cpc => {
      :amount => {
        :micro_amount => 10000000
      }
    }
  },

  :criteria => [
    # keyword_criterion
    {
      :xsi_type => 'BiddableAdGroupCriterion',
      :criterion => { :xsi_type => 'Keyword', :text => 'ataxo', :match_type => 'BROAD' }
    },
    # placement_criterion
    {
      :xsi_type => 'BiddableAdGroupCriterion',
      :criterion => { :xsi_type => 'Placement', :url => 'http://www.ataxo.cz' }
    }
  ],

  :ads => [
    {
      :xsi_type => 'TextAd',
      :headline => "Ataxo TextAd #%d" % (Time.new.to_f * 1000).to_i,
      :description1 => 'Visit the Red Planet in style.',
      :description2 => 'Low-gravity fun for everyone!',
      :url => 'http://www.example.com',
      :display_url => 'www.example.com'
    }
  ]

}
 
p Adapi::AdGroup.create(:data => ad_group_data)
