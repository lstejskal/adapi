# encoding: utf-8

FactoryGirl.define do

  a_bidding_strategy = { :xsi_type => 'BudgetOptimizer', :bid_ceiling => 55 }

  factory :valid_campaign, :class => Adapi::Campaign do
    sequence(:id)             { |n| n }
    sequence(:name)           { |n| 'Campaign #%s' % n }
    status                    'PAUSED'
    bidding_strategy          a_bidding_strategy
    budget                    50
  end

end