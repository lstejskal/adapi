# encoding: utf-8

require 'adapi'

# add campaign with basic data only
# this script is used as an include in other scripts

$campaign_data = {
  :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',

  # NEW Bidding strategy
  :bidding_strategy_configuration => { 
    :bidding_scheme => {
      :bid_ceiling => {:micro_amount=>20000000},
      :xsi_type => 'BudgetOptimizerBiddingScheme',
    }
  },

  # Specify delivery Method
  :budget => {:amount => 50, :delivery_method => 'ACCELERATED' }, 

  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false
  }
}

$campaign = Adapi::Campaign.create($campaign_data)

unless $campaign.errors.empty?

  puts "ERROR WHEN CREATING CAMPAIGN:"
  pp $campaign.errors.full_messages

else

  puts "\nCREATED CAMPAIGN #{$campaign[:id]}\n"
  pp $campaign.attributes

end
