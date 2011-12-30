# encoding: utf-8

require 'test_helper'

module Adapi
  class CampaignCriterionTest < Test::Unit::TestCase
  
    context "self.create_criterion" do

      should "parse :language criterion to Google format" do
        assert_equal CampaignCriterion.create_criterion(:language, 'en'),
          {:xsi_type => 'Language', :id => 1000}
      end

      should "automatically convert :language value to lowercase" do
        assert_equal CampaignCriterion.create_criterion(:language, 'CS'),
          {:xsi_type => 'Language', :id => 1021}
      end

      should "parse :geo / :country and :province targets" do
        assert_equal CampaignCriterion.create_criterion(:geo, {:country => 'CZ', :province => 'CZ-PR'}),
          [
            {:xsi_type => 'CountryTarget', :excluded => false, :country_code => 'CZ'},
            {:xsi_type => 'ProvinceTarget', :excluded => false, :province_code => 'CZ-PR'}
          ]
      end

      should "automatically convert :geo / :country and :province targets to uppercase" do
        assert_equal CampaignCriterion.create_criterion(:geo, {:country => 'cz', :province => 'cz-pr'}),
          [
            {:xsi_type => 'CountryTarget', :excluded => false, :country_code => 'CZ'},
            {:xsi_type => 'ProvinceTarget', :excluded => false, :province_code => 'CZ-PR'}
          ]
      end

      should "parse :geo / :proximity targets" do
        assert_equal CampaignCriterion.create_criterion(:geo,
          {:proximity => {:geo_point => '38.89859,-77.035971', :radius => '10 km'}}),
          [{ :xsi_type => 'ProximityTarget', :excluded => false,
            :radius_in_units => 10, :radius_distance_units => 'KILOMETERS',
            :geo_point => {
              :longitude_in_micro_degrees => 38898590,
              :latitude_in_micro_degrees => -77035971
            }
          }]
      end

    end

  end
end
