
require 'adapi'

# create ad group
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

ad = Adapi::Ad::TextAd.create(
  :ad_group_id => $ad_group[:id],
  :headline => "Code like Neo",
  :description1 => 'Need mad coding skills?',
  :description2 => 'Check out my new blog!',
  :url => 'http://www.demcodez.com',
  :display_url => 'http://www.demcodez.com',
  :status => 'PAUSED'
)

if ad
  p "OK"
  p ad.data
else
  p "ERROR"
  p ad.errors.messages
end
