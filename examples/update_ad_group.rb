# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign_id = $campaign.id

$ad_group = Adapi::AdGroup.create(
  :campaign_id => $campaign_id,
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
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
)

$ad_group_id = $ad_group.id

# fetch ids of ad_group and ads
$ad_group = Adapi::AdGroup.find(:first, :id => $ad_group_id, :campaign_id => $campaign_id)

p "CREATED ad_group #{$ad_group.id} for campaign #{$ad_group.campaign_id}"
pp $ad_group.attributes

result = $ad_group.update(
  :name => "UPDATED #{$ad_group.name}",
  :status => 'ENABLED',

  :keywords => ['dem codez', '"neo coder"', '[-code]' ],

  :ads => [
    {
      :headline => "Code like Neo",
      :description1 => 'Need mad coding skills?',
      :description2 => 'Check out my new blog!',
      :url => 'http://www.demcodez.com',
      :display_url => 'http://www.demcodez.com'
    }
  ]
)

unless result
  puts "ERRORS:"
  puts $ad_group.errors.full_messages.join("\n")
else
  # fetch ids of ad_group and ads
  $ad_group = Adapi::AdGroup.find(:first, :id => $ad_group_id, :campaign_id => $campaign_id)

  p "UPDATED ad_group #{$ad_group.id} for campaign #{$ad_group.campaign_id}"
  pp $ad_group.attributes
end
