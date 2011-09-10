
require 'adapi'

# create ad group
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

ad_data = {
  :ad_group_id => $ad_group[:id],
  :xsi_type => 'TextAd',
  :headline => "Code like Neo",
  :description1 => 'Need mad coding skills?',
  :description2 => 'Check out my new blog!',
  :url => 'http://www.demcodez.com',
  :display_url => 'http://www.demcodez.com'
}

p Adapi::Ad.create(:data => ad_data)
