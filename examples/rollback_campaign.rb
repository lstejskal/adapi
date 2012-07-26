# encoding: utf-8

require 'adapi'

# Tries to create a campaign and fails because ad is intentionally left 
# without url. We test if campaign then rollbacks correctly:
# * status should be set to DELETED 
# * renamed so the original campaign name isn't blocked

campaign_data = {
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
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

unless $campaign.errors.empty?

  puts "\nERRORS WHEN UPDATING CAMPAIGN #{$campaign.id}:"
  pp $campaign.errors.full_messages

  puts "\nROLLBACKING CAMPAIGN #{$campaign.id}\n"

  $campaign.rollback!

  unless $campaign.errors.empty?

    puts "\nERRORS WHEN ROLLBACKING CAMPAIGN #{$campaign.id}:"
    pp $campaign.errors.full_messages

  else

    puts "\nOK, ROLLBACKED CAMPAIGN #{$campaign.id}"

    $campaign = Adapi::Campaign.find($campaign.id)

    puts "\nCAMPAIGN DATA:"
    pp $campaign.attributes

  end

else

  puts "\nCREATED CAMPAIGN #{$campaign.id}"

  puts "\nSOMETHING IS WRONG, THIS SHOULDN'T HAPPEN!"

end
