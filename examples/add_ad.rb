
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
  }
}
 
ad_group = Adapi::AdGroup.create(:data => ad_group_data)

ad_data = {
  :ad_group_id => ad_group[:id],
  :xsi_type => 'TextAd',
  :headline => "Ataxo TextAd #%d" % (Time.new.to_f * 1000).to_i,
  :description1 => 'Visit the Red Planet in style.',
  :description2 => 'Low-gravity fun for everyone!',
  :url => 'http://www.example.com',
  :display_url => 'www.example.com'
}

p Adapi::Ad.create(:data => ad_data)
