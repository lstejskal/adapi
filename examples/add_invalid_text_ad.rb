
require 'adapi'

# PolicyViolations will appread only in production, not in sandbox
#
#Adapi::Config.load_settings
#Adapi::Config.set(:production_settings)
#
#pp "Running in #{Adapi::Config.read[:service][:environment]}"

# create ad group
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
  p "OK"
  p $ad.data
else
  p "ERROR"
  p $ad.errors.messages
end
