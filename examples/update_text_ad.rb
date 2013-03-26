
require 'adapi'

require_relative 'add_text_ad'

$new_ad = $ad.update(
  :status => 'ENABLED',
  :headline => "Code like Trinity",
  :description1 => 'Need mad update skills?',
  :description2 => 'Check out my updates!',
  :url => 'http://www.demupdatez.com',
  :display_url => 'http://www.demupdatez.com'
)

$new_ad = Adapi::Ad::TextAd.find(:first, :ad_group_id => $new_ad.ad_group_id, :id => $new_ad.id )

puts "\nUPDATED (AND RELOADED) AD:"
pp $new_ad.attributes
