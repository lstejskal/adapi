
require 'adapi'

# create campaign
require 'add_bare_campaign'

# create ad group

ad_group_data = {
  :name => "Ataxo AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :campaign_id => $campaign[:id],
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
