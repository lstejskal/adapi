# encoding: utf-8

require 'test_helper'

module Adapi
  class CreateCampaignTest < Test::Unit::TestCase
    context "non-existent Campaign" do
      should "not be found" do
        # FIXME randomly generated id, but it might actually exist        
        assert_nil Adapi::Campaign.find(Time.new.to_i)
      end
    end

    context "existing Campaign" do
      setup do 
        @campaign_data = {
          :name => "Campaign #%d" % (Time.new.to_f * 1000).to_i,
          :status => 'PAUSED',
          :bidding_strategy => { :xsi_type => 'BudgetOptimizer', :bid_ceiling => 55 },
          :budget => 50,      
          :network_setting => {
            :target_google_search => true,
            :target_search_network => true,
            :target_content_network => false,
            :target_content_contextual => false
          }
        }
        
        c = Adapi::Campaign.create(@campaign_data)
        
        @campaign = Adapi::Campaign.find(c.id)
      end

      # this basically tests creating bare campaign
      should "be found" do
        assert_not_nil @campaign

        assert_equal @campaign_data[:status], @campaign.status
        assert_equal @campaign_data[:name], @campaign.name
      end      

      should "still be found after deletion" do
        @campaign.delete

        deleted_campaign = Adapi::Campaign.find(@campaign.id)

        assert_equal "DELETED", deleted_campaign.status
        assert_equal @campaign_data[:name], deleted_campaign.name
      end      

    end

  end
end
