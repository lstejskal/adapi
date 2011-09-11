
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

  :keywords => [
    { :text => 'dem codez', :match_type => 'BROAD', :negative => false },
    { :text => 'top coder', :match_type => 'PHRASE', :negative => false },
    { :text => 'code', :match_type => 'EXACT', :negative => true }
  ],

  :ads => [
    {
      :headline => "Code like Neo",
      :description1 => 'Need mad coding skills?',
      :description2 => 'Check out my new blog!',
      :url => 'http://www.demcodez.com',
      :display_url => 'http://www.demcodez.com'
    }
  ]

}
 
$ad_group = Adapi::AdGroup.create(ad_group_data)

p $ad_group
