
require 'adapi'

# PolicyViolations will appread only in production, not in sandbox
#
#Adapi::Config.load_settings
#Adapi::Config.set(:production_settings)
#
#pp "Running in #{Adapi::Config.read[:service][:environment]}"

require_relative 'add_bare_ad_group'

$ad = Adapi::Ad::TextAd.create(
  :ad_group_id => $ad_group[:id],
  :headline => "Code a Blog",
  :description1 => 'Need mad coding skill?',
  :description2 => 'Check out my new blog!!!', # !!! - this is invalid
  :url => 'http://www.demcodez.com',
  :display_url => 'http://www.demcodez.com',
  :status => 'PAUSED'
)

if $ad.errors.empty?
  puts "OK"
  pp $ad.attributes
else
  puts "ERROR"
  puts $ad.errors.full_messages.join("\n")
end
