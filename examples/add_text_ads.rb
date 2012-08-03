
require 'adapi'

require_relative 'add_bare_ad_group'

$ad = Adapi::Ad::TextAd.create( :ads => [
  {
    :ad_group_id => $ad_group[:id],
    :headline => "Code like Neo",
    :description1 => 'Need mad coding skills?',
    :description2 => 'Check out my new blog!',
    :url => 'http://www.demcodez.com',
    :display_url => 'http://www.demcodez.com',
    :status => 'PAUSED'
  },

  {
    :ad_group_id => $ad_group[:id],
    :headline => "Code like Trinity",
    :description1 => 'The power of awesomeness?',
    :description2 => 'Check out my new blog!',
    :url => 'http://www.demcodez.com',
    :display_url => 'http://www.demcodez.com',
    :status => 'PAUSED'
  },

  {
    :ad_group_id => $ad_group[:id],
    :headline => "Code like Morpheus",
    :description1 => 'Unleash the power of Matrix',
    :description2 => 'Check out my new blog',
    :url => 'http://www.demcodez.com',
    :display_url => 'http://www.demcodez.com',
    :status => 'PAUSED'
  }
] )

puts "\nCREATED ADS FOR AD GROUP #{$ad_group[:id]}:"

$ads = Adapi::Ad::TextAd.find( :all, :ad_group_id => $ad_group[:id] )

$ads.each_with_index do |ad, i|
  puts "\nAD NR. #{i + 1}:"
  pp ad.attributes
end
