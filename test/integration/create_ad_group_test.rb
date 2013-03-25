# encoding: utf-8

require 'test_helper'
require 'integration_test_helper'

module Adapi
  class AdGroupCreateTest < Test::Unit::TestCase
    context "non-existent ad group" do
      should "not be found" do
        assert assert_nil Adapi::AdGroup.find(:first, :campaign_id => Time.new.to_i)
      end
    end

    context "existing ad group" do
      setup do 
        @campaign_id = create_bare_campaign! 

        @ad_group_data = {
          :campaign_id => @campaign_id,
          :name => "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
          :status => 'ENABLED',
          :bids => {
            :xsi_type => 'BudgetOptimizerAdGroupBids',
            :proxy_keyword_max_cpc => 15
          }
        }
        
        ag = Adapi::AdGroup.create(@ad_group_data)
        
        @ad_group = Adapi::AdGroup.find(:first, :id => ag.id, :campaign_id => @campaign_id)
      end

      should "be found" do
        assert_not_nil @ad_group

        assert_equal @ad_group_data[:status], @ad_group.status
        assert_equal @ad_group_data[:name], @ad_group.name        
      end      

      should "not be found after deletion" do
        @ad_group.delete

        assert_nil Adapi::AdGroup.find(:first, :id => @ad_group.id, :campaign_id => @campaign_id)
      end

    end

  end
end
