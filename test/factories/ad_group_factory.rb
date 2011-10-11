# encoding: utf-8

Factory.define :ad_group, :class => Adapi::AdGroup do |f|
  f.sequence(:campaign_id)    { |n| n }
  f.name                      "AdGroup %d" % (Time.new.to_f * 1000).to_i
  f.status                    'ENABLED'
  # f.bids                    {}
  f.keywords                  [ 'dem codez', '"top coder"', '[-code]' ]
end

=begin
ad_group_data = {
  :bids => {
    :xsi_type => 'ManualCPCAdGroupBids',
    :keyword_max_cpc => {
      :amount => {
        :micro_amount => 10000000
      }
    }
  },
=end
