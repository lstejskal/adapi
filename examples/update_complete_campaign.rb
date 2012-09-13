# encoding: utf-8

require 'adapi'

# create campaign by single command, with campaing targets, with ad_groups
# including keywords and ads

$ad_group_names = [
  "AdGroup 01 #%d" % (Time.new.to_f * 1000).to_i,
  "AdGroup 02 #%d" % (Time.new.to_f * 1000).to_i
]

campaign_data = {
  # basic data for campaign
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => 'ManualCPC',
  :budget => 50,
  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false
  },

  :criteria => {
    :language => [ :en, :cs ],
    :geo => { :proximity => { :geo_point => '38.89859,-77.035971', :radius => '10 km' } }
  },

  :ad_groups => [
    {
      :name => $ad_group_names[0],
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
      :name => $ad_group_names[1],
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

# PS: changes in ad_groups:
# * delete first ad_group
# * change second ad_group
# * add new ad_group

$campaign.update(
  :id => $campaign[:id],
  :status => 'ACTIVE',
  :name => "UPDATED #{$campaign[:name]}",
  :bidding_strategy => { 
    :xsi_type => 'BudgetOptimizer', 
    :bid_ceiling => 20 
  },
  :budget => 75,

  # deletes all criteria (except :platform) and create these new ones
  :criteria => {
    :language => [ :sk ],
  },

  :ad_groups => [
    # no match here for $ad_group_names[0], so it's going to be deleted

    # this ad_group will be created
    {
      :name => "UPDATED " + $ad_group_names[0],
      :status => 'ENABLED',

      :keywords => [ 'neo update', 'dem codezzz', '"top coder"' ],

      :ads => [
        {
          :headline => "Update like Neo",
          :description1 => 'Need mad coding skills?',
          :description2 => 'Check out my new blog!',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        }
      ]
    },

    # this ad_group is going to be updated
    {
      :name =>  $ad_group_names[1],
      :status => 'ENABLED', # from PAUSED

      :keywords => [ 'dem updatez', 'update trinity', 'update morpheus' ],

      :ads => [
        {
          :headline => "Update like Trinity",
          :description1 => 'The power of updates?',
          :description2 => 'Check out my new blog!',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        },

        {
          :headline => "Update like Morpheus",
          :description1 => 'Unleash the power of updates',
          :description2 => 'Check out my new blog',
          :url => 'http://www.demcodez.com',
          :display_url => 'http://www.demcodez.com'
        }        
      ]
    }    
  ]
)

unless $campaign.errors.empty?

  puts "ERROR WHEN UPDATING AD GROUPS:"
  puts $campaign.errors.full_messages.join("\n")

else

  # reload campaign
  $campaign = Adapi::Campaign.find_complete($campaign.id)

  $campaign_attributes = $campaign.attributes
  $criteria = $campaign_attributes.delete(:criteria)
  $ad_groups = $campaign_attributes.delete(:ad_groups)

  puts "\nCAMPAIGN UPDATED\n"

  puts "\nCAMPAIGN DATA:"
  pp $campaign_attributes

  puts "\nCAMPAIGN CRITERIA:"
  pp $criteria

  puts "\nAD GROUPS (#{$ad_groups.size}):"
  $ad_groups.each_with_index do |ad_group, i| 
    puts "\nAD GROUP #{i + 1}:\n"
    pp ad_group
  end

end
