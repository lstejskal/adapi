
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

# create ad group

ad_group_data = {
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
  },

  :criteria => [
    { # keyword_criterion
      :xsi_type => 'BiddableAdGroupCriterion',
      :criterion => { :xsi_type => 'Keyword', :text => 'codez', :match_type => 'BROAD' }
    },
    { # placement_criterion
      :xsi_type => 'BiddableAdGroupCriterion',
      :criterion => { :xsi_type => 'Placement', :url => 'http://www.blogger.com' }
    }
  ],

  :ads => [
    {
      :xsi_type => 'TextAd',
      :headline => "Code like Neo",
      :description1 => 'Need mad coding skills?',
      :description2 => 'Check out my new blog!',
      :url => 'http://www.demcodez.com',
      :display_url => 'http://www.demcodez.com'
    }
  ]

}
 
p Adapi::AdGroup.create(:data => ad_group_data)
