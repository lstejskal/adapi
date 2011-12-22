# encoding: utf-8

require 'adapi'

# create campaign
require File.join(File.dirname(__FILE__), 'add_bare_ad_group')

# find all ad_groups for campaign
 
$ad_groups = Adapi::AdGroup.find :all, :campaign_id => $campaign.to_param

p "Found %s ad groups." % $ad_groups.size

$ad_groups.each do |ad_group|
  puts "ID: %s, NAME %s, STATUS %s" % [ ad_group[:id], ad_group[:name], ad_group[:status] ]
  puts "KEYWORDS: %s" % ad_group[:keywords].join(", ")
  puts "ADS:"
  ad_group[:ads].each do |ad|
    puts "\nheadline: %s" % ad[:headline] 
    puts "description1: %s" % ad[:description1]
    puts "description2: %s" % ad[:description2]
    puts "url: %s" % ad[:url]
    puts "display_url: %s" % ad[:display_url]
  end
end
