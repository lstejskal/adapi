# encoding: utf-8

require 'adapi'

# this test should not raise an exception (sic!)

$search_params = { :city => 'São Paulo' }

$location = Adapi::Location.find($search_params)

puts "\nSearched for: " + $search_params.inspect

if $location.nil?
  puts "Not found."
else
  # puts "Found Location ID: #{Adapi::Location.location_tree($location)}"
  puts "Found Location ID: #{$location[:id]}"
end
