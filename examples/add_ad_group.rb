# encoding: utf-8

require 'adapi'

require_relative 'add_bare_campaign'

$ad_group_data = {
  :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'ENABLED',
  :campaign_id => $campaign[:id],

  #NEW WAY
  :bidding_strategy_configuration =>  { 
    :bids => [
      {
        # The 'xsi_type' field allows you to specify the xsi:type of the
        # object being created. It's only necessary when you must provide
        # an explicit type that the client library can't infer.
        :xsi_type => 'CpcBid',
        :bid => {:micro_amount => 10000000},
        :content_bid => {:micro_amount => 2000000}
      }
    ]
  },

  :keywords => [ 'dem codez', '"top coder"', '[-code]' ],

  :ads => [
    {
      :headline => "Code like Neo",
      :description1 => 'Need mad coding skills?',
      :description2 => 'Check out my new blog!',
      :url => 'http://www.demcodez.com',
      :display_url => 'http://www.demcodez.com'
    }
  ]
}
 
$ad_group = Adapi::AdGroup.create($ad_group_data)

unless $ad_group.errors.empty?

  puts "ERROR WHEN CREATING AD GROUP:"
  pp $ad_group.errors.full_messages

else

  puts "\nCREATED AD GROUP #{$ad_group[:id]} FOR CAMPAIGN #{$ad_group[:campaign_id]}\n"
  pp $ad_group.attributes

end
