# encoding: utf-8

require 'test_helper'

module Adapi
  class CampaignTest < Test::Unit::TestCase
  
    context "invalid Campaign" do
      setup do
        @campaign = Campaign.new
      end

      should "not be valid?" do
        assert ! @campaign.valid?
      end

      should "return error messages" do
        @campaign.valid? # creates errors messages
        assert ! @campaign.errors.full_messages.empty?
      end
    end

    context "Campaign status" do
      
      should "be required" do
        campaign = FactoryGirl.build(:valid_campaign, :status => nil)
        assert ! campaign.valid?
        assert campaign.errors.has_key? :status
      end
      
      should "should be only ACTIVE, DELETED or PAUSED" do
        campaign = FactoryGirl.build(:valid_campaign, :status => "TEST")
        assert ! campaign.valid?
        assert campaign.errors.has_key? :status
      end

    end

    context "Campaign name" do
      
      should "be required" do
        campaign = FactoryGirl.build(:valid_campaign, :name => nil)
        assert ! campaign.valid?
        assert campaign.errors.has_key? :name
      end

    end
    
  end
end
