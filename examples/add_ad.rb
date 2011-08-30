
require 'adapi'

# create ad group
require 'add_bare_ad_group'

ad_data = {
  :ad_group_id => $ad_group[:id],
  :xsi_type => 'TextAd',
  :headline => "Fly to Mars %d" % (Time.new.to_f * 1000).to_i,
  :description1 => 'Visit the Red Planet in style.',
  :description2 => 'Low-gravity fun for everyone!',
  :url => 'http://www.example.com',
  :display_url => 'www.example.com'
}

p Adapi::Ad.create(:data => ad_data)
