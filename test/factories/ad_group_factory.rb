# encoding: utf-8

the_bids = { :xsi_type => 'ManualCPCAdGroupBids', :keyword_max_cpc => 10 }

FactoryGirl.define do

  factory :ad_group, :class => Adapi::AdGroup do
    sequence(:campaign_id)    { |n| n }
    name                      "AdGroup %d" % (Time.new.to_f * 1000).to_i
    status                    'ENABLED'
    bids                      the_bids
    keywords                  [ 'dem codez', '"top coder"', '[-code]' ]
  end

end
