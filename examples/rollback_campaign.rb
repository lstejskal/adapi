# encoding: utf-8

require 'adapi'

# This test tries to create a complete campaign and fails because ad is
# intentionally left without url. The point is to test how create_campaign
# fails: campaign status should be set to DELETED and name changed (so the
# name isn't blocked and another campaign can be created with the same name
# eventually)

campaign_data = {
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  # Automatic CPC: BudgetOptimizer or ManualCPC
  :bidding_strategy => { :xsi_type => 'BudgetOptimizer', :bid_ceiling => 100 },
  :budget => { :amount => 50, :delivery_method => 'STANDARD' },

  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false,
    :target_content_contextual => false
  },

  :criteria => {
    :language => [ 'en', 'cs' ],
    :geo => { :proximity => { :geo_point => '38.89859,-77.035971', :radius => '10 km' } }
  },

  :ad_groups => [
    {
      :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
      :status => 'ENABLED',

      :keywords => [ 'dem codez', '"top coder"', "[-code]" ],

      :ads => [
        {
          :headline => "Code like Neo",
          :description1 => 'Need mad coding skills?',
          :description2 => 'Check out my new blog!',
          :url => '', # THIS SHOULD FAIL
          :display_url => 'http://www.demcodez.com'
        }
      ]
    }
  ]

}
 
$campaign = Adapi::Campaign.create(campaign_data)

p "Campaign ID #{$campaign.id} created"
p "with status DELETED and changed name"
pp $campaign.attributes

p "with errors:"
pp $campaign.errors.to_a
