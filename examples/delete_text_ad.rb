
require 'adapi'

# create ad group
require_relative 'add_text_ad'

$ad_id = $ad.id

puts "\nDELETED AD #{$ad_id}: " + ($ad.destroy ? "true" : "false")

$ad = Adapi::Ad::TextAd.find(:first, :ad_group_id => $ad_group.id, :id => $ad_id )

puts "TRYING TO FIND IT: " + ($ad.present? ? $ad.attributes : "nil")
