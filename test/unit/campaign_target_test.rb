# encoding: utf-8

require 'test_helper'

module Adapi
  class CampaignTargetTest < Test::Unit::TestCase
  
    context "self.create_targets" do

      should "parse :language targets" do
        assert_equal CampaignTarget.create_targets(:language, ['en', 'cs']),
          [{:language_code => 'en'}, {:language_code => 'cs'}]
      end

      should "automatically convert :language targets to lowercase" do
        assert_equal CampaignTarget.create_targets(:language, ['EN', 'CS']),
          [{:language_code => 'en'}, {:language_code => 'cs'}]
      end

      should "parse :geo / :country and :province targets" do
        assert_equal CampaignTarget.create_targets(:geo, {:country => 'CZ', :province => 'CZ-PR'}),
          [
            {:xsi_type => 'CountryTarget', :excluded => false, :country_code => 'CZ'},
            {:xsi_type => 'ProvinceTarget', :excluded => false, :province_code => 'CZ-PR'}
          ]
      end

      should "automatically convert :geo / :country and :province targets to uppercase" do
        assert_equal CampaignTarget.create_targets(:geo, {:country => 'cz', :province => 'cz-pr'}),
          [
            {:xsi_type => 'CountryTarget', :excluded => false, :country_code => 'CZ'},
            {:xsi_type => 'ProvinceTarget', :excluded => false, :province_code => 'CZ-PR'}
          ]
      end

      should "parse :geo / :proximity targets" do
        assert_equal CampaignTarget.create_targets(:geo,
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
