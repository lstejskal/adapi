
require 'adapi'

# create campaign by single command, with campaing targets, with ad_groups
# including keywords and ads

campaign_data = {
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
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
  },

  :targets => {
    :language => [ 'en', 'cs' ],
    :geo => { :country => 'CZ' }
  },

  :ad_groups => [
    {
      :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
      :status => 'ENABLED',
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
  ]

}
 
p Adapi::Campaign.create(campaign_data)
