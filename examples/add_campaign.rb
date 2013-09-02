# encoding: utf-8

require 'adapi'

# create campaign by single command, with campaing targets, with ad_groups
# including keywords and ads

campaign_data = {
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  # Automatic CPC: BudgetOptimizer or ManualCPC
  #OLD METHOD 
  :bidding_strategy => { :xsi_type => 'BudgetOptimizer', :bid_ceiling => 100 },

  #Plain budget
  :budget => 50,

  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false
  },

  # PS: :targets key is obsolete, this should be named :criteria, but it still works
  :criteria => {
    :language => [ :en, :cs ],
    # TODO test together with city target
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
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        }
      ]
    }
  ]

}

$campaign = Adapi::Campaign.new(campaign_data)

$campaign.create

unless $campaign.errors.empty?

  puts "ERROR WHEN CREATING CAMPAIGN:"
  pp $campaign.errors.full_messages

else

  puts "\nCREATED CAMPAIGN #{$campaign[:id]}\n"

  $campaign = Adapi::Campaign.find($campaign[:id])

  puts "\nCAMPAIGN DATA:"
  pp $campaign.attributes

  $campaign_criteria = Adapi::CampaignCriterion.find( :campaign_id => $campaign[:id] )

  puts "\nCRITERIA:"
  pp $campaign_criteria

end
