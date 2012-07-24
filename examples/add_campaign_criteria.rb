# encoding: utf-8

require 'adapi'

require_relative 'add_bare_campaign'

$campaign_criteria_data = {
  :campaign_id => $campaign[:id],
  :criteria => {
    :language => %w{ en cs },

    :location => { 
      # :id => 21137
      # :name => { :city => 'Prague', :region => 'CZ-PR', :country => 'CZ' }
      :proximity => { :geo_point => '50.083333,14.366667', :radius => '50 km' }
    },

    # add custom platform criteria
    :platform => [ { :id => 30001} ]
  }
}

$campaign_criteria = Adapi::CampaignCriterion.new($campaign_criteria_data)

$campaign_criteria.create

unless $campaign_criteria.errors.empty?

  puts "ERROR WHEN CREATING CAMPAIGN CRITERIA FOR CAMPAIGN #{$campaign[:id]}:"
  pp $campaign_criteria.errors.full_messages

else

  puts "\nCREATED CAMPAIGN CRITERIA FOR CAMPAIGN #{$campaign[:id]}\n"

  $campaign_criteria = Adapi::CampaignCriterion.find( :campaign_id => $campaign[:id] )

  puts "\nCRITERIA:"
  pp $campaign_criteria

end
