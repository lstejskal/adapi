require 'test_helper'

module Adapi
  class CampaignTargetTest < Test::Unit::TestCase
  
    context "self.create_targets" do

      should "parse :language targets" do
        assert_equal CampaignTarget.create_targets(:language, ['en', 'cs']),
          [{:language_code => 'en'}, {:language_code => 'cs'}]
      end

      should "parse :geo / :country targets" do
        assert_equal CampaignTarget.create_targets(:geo, {:country => 'CZ'}),
          [{:xsi_type => 'CountryTarget', :excluded => false, :country_code => 'CZ'}]
      end

    end

  end
end
