
require 'adapi'

# create factory for campaign and ad_groups, can be used even in development

campaign_data = {
  :name => "Ataxo Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  # vetsinou se pouziva automaticky bidding
  :bidding_strategy => { :xsi_type => 'ManualCPC' },
  :budget => {
    :period => 'DAILY',
    :amount => { :micro_amount => 50000000 },
    :delivery_method => 'STANDARD'
  },

  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false,
    :target_content_contextual => false
  }
}

campaign = Adapi::Campaign.new(:data => campaign_data).create

campaign_target_data = {
  :campaign_id => campaign[:id],
  :targets => {
    :language => [ 'en', 'cs' ],
    :geo => {
      :country => 'CZ'
      # :province => [ 'CZ-PR', 'CZ-KA' ]
      # :proximity => { :geo_point => '',
    }
  }
}

p Adapi::CampaignTarget.create(campaign_target_data)
