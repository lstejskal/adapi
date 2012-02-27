# encoding: utf-8

require 'adapi'

# find location by LocationService

$search_params = [
  { :country => 'CZ' },
  { :country => 'CZ', :province => 'Prague' },
  { :country => 'CZ', :province => 'Prague', :city => 'Prague' },
  { :province => 'Prague' },
  { :city => 'Prague' }
]
 
$search_params.each do |params| 
  $location = Adapi::Location.find(params)

  puts "\nSearched for: " + params.inspect
  # puts "Found Location ID: #{Adapi::Location.location_tree($location)}"
  puts "Found Location ID: #{$location[:id]}"
end
