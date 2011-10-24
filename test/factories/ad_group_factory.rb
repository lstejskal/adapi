# encoding: utf-8

the_bids = { :xsi_type => 'ManualCPCAdGroupBids', :keyword_max_cpc => 10 }

Factory.define :ad_group, :class => Adapi::AdGroup do |f|
  f.sequence(:campaign_id)    { |n| n }
  f.name                      "AdGroup %d" % (Time.new.to_f * 1000).to_i
  f.status                    'ENABLED'
  f.bids                      the_bids
  f.keywords                  [ 'dem codez', '"top coder"', '[-code]' ]
end
