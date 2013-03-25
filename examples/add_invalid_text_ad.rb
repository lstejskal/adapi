
require 'adapi'

require_relative 'add_bare_ad_group'

# Example workflow:
# * "ho", which is suspicious word in English, will trigger exemptable PolicyViolationError
# * adapi performs exemption request(s) and text_ad will eventually pass

$ad = Adapi::Ad::TextAd.create(
  :ad_group_id => $ad_group[:id],
  :headline => "Neo Blog - poznej ho",
  :description1 => 'Poznej ho kdekoliv',
  :description2 => 'Check out my ho blog',
  :url => 'http://www.demcodez.com',
  :display_url => 'http://www.demcodez.com',
  :status => 'PAUSED'
)

if $ad.errors.empty?
  puts "INVALID TEXT AD CREATED"
  $fresh_ad = Adapi::Ad::TextAd.find(:first, :id => $ad.id, :ad_group_id => $ad_group[:id])
  pp $fresh_ad.attributes
else
  puts "ERRORS:"
  pp $ad.errors.messages
end
