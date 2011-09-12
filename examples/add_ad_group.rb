
require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_campaign')

# create ad group

ad_group_data = {
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :campaign_id => $campaign[:id],

  :keywords => [ 'dem codez', '"top coder"', '[-code]' ],

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

p "Created ad_group ID #{$ad_group.id} for campaign ID #{$ad_group.campaign_id}"
p $ad_group.attributes
