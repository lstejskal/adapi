
require 'adapi'

require_relative 'add_bare_ad_group'

$ad = Adapi::Ad::TextAd.create(
  :ad_group_id => $ad_group[:id],
  :headline => "Code like Neo",
  :description1 => 'Need mad coding skills?',
  :description2 => 'Check out my new blog!',
  :url => 'http://www.demcodez.com',
  :display_url => 'http://www.demcodez.com',
  :status => 'PAUSED'
)

$ad = Adapi::Ad::TextAd.find(:first, :ad_group_id => $ad_group.id, :id => $ad.id )

puts "\nCREATED (AND RELOADED) AD:"
pp $ad.attributes
