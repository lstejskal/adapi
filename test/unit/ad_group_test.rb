# encoding: utf-8

require 'test_helper'

module Adapi
  class AdGroupTest < Test::Unit::TestCase

    context "valid new instance" do
      setup do
        @ad_group = FactoryGirl.build(:ad_group)
      end

      should "be valid" do
        assert @ad_group.valid?
      end

      should "parse :bids correctly" do
        ag = AdGroup.new( :bids => { :xsi_type => 'ManualCPCAdGroupBids', :proxy_keyword_max_cpc => 10 } )

        assert_equal ag.bidding_strategy_configuration,
        {:bids=>
            [{:xsi_type=>"CpcBid",
              :bid=>{:micro_amount=>10000000},
              :content_bid=>{:micro_amount=>10000000}}]}
      end

      should "parse :bidding_strategy_configuration correctly" do
        ag = AdGroup.new( :bidding_strategy_configuration => {:bids=>[{:xsi_type=>"CpcBid",:bid=>{:micro_amount=>10000000},:content_bid=>{:micro_amount=>10000000}}]} )

        assert_equal ag.bidding_strategy_configuration,
        {:bids=>
            [{:xsi_type=>"CpcBid",
              :bid=>{:micro_amount=>10000000},
              :content_bid=>{:micro_amount=>10000000}}]}
      end

      context " / data method" do
        should "return params in hash" do
          assert @ad_group.attributes.is_a?(Hash)
          assert_equal @ad_group.name, @ad_group.attributes[:name]
        end
      end

    end

  end
end
