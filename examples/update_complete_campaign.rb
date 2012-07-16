# encoding: utf-8

require 'adapi'

# create campaign by single command, with campaing targets, with ad_groups
# including keywords and ads

campaign_data = {
  # basic data for campaign
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => { 
    :xsi_type => 'BudgetOptimizer', 
    :bid_ceiling => 20 
  },
  :budget => 50,
  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false,
    :target_content_contextual => false
  },

  :criteria => {
    :language => [ :en, :cs ],
    :geo => { :proximity => { :geo_point => '38.89859,-77.035971', :radius => '10 km' } }
  },

  :ad_groups => [
    {
      :name => "AdGroup 01 #%d" % (Time.new.to_f * 1000).to_i,
      :status => 'ENABLED',

      :keywords => [ 'neo', 'dem codez', '"top coder"', "[-code]" ],

      :ads => [
        {
          :headline => "Code like Neo",
          :description1 => 'Need mad coding skills?',
          :description2 => 'Check out my new blog!',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        }
      ]
    },

    {
      :name => "AdGroup 02 #%d" % (Time.new.to_f * 1000).to_i,
      :status => 'PAUSED',

      :keywords => [ 'dem codez', 'trinity', 'morpheus', '"top coder"', "[-code]" ],

      :ads => [
        {
          :headline => "Code like Trinity",
          :description1 => 'The power of awesomeness?',
          :description2 => 'Check out my new blog!',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        },

        {
          :headline => "Code like Morpheus",
          :description1 => 'Unleash the power of Matrix',
          :description2 => 'Check out my new blog',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        }        
      ]
    }    
  ]

}
 
$campaign = Adapi::Campaign.create(campaign_data)
p "Created campaign ID #{$campaign.id}"

# reload campaign
$campaign = Adapi::Campaign.find_complete($campaign.id)

$campaign_attributes = $campaign.attributes
$criteria = $campaign_attributes.delete(:criteria)
$ad_groups = $campaign_attributes.delete(:ad_groups)

pp "\nBASIC CAMPAIGN DATA:"
pp $campaign_attributes
pp "\nAD GROUPS (#{$ad_groups.size}):"
pp $ad_groups.map(&:attributes)

