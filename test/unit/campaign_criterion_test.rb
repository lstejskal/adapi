# encoding: utf-8

require 'test_helper'

module Adapi
  class CampaignCriterionTest < Test::Unit::TestCase
  
    context "language alias" do

      should "be converted to language id " do
        assert_equal CampaignCriterion.create_criterion(:language, 'en'),
          {:xsi_type => 'Language', :id => 1000}
      end

      should "be automatically converted to lowercase" do
        assert_equal CampaignCriterion.create_criterion(:language, 'CS'),
          {:xsi_type => 'Language', :id => 1021}
      end

    end

  end
end
