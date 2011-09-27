
require 'adapi'

# find all campaigns for customer
 
$campaigns = Adapi::Campaign.find :all

p "Found %s campaigns." % $campaigns.size

$campaigns.each do |campaign|
  p "ID: %s, NAME %s" % [ campaign[:id], campaign[:name] ]
end
