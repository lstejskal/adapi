# encoding: utf-8

# FIXME for some reason, tests don't return errors, only quietly fail

require 'rubygems'
gem 'minitest'
require 'test/unit'
require 'turn'
require 'shoulda'
require 'fakeweb'
require 'factory_girl'
require 'mocha/setup'

# always test the latest version of the gem
# TODO make it an option only through ENV variable switch
require File.join(File.dirname(__FILE__), '..', 'lib', 'adapi')

# load factories
Dir[ File.join(File.dirname(__FILE__), 'factories', '*.rb') ].each { |f| require f }

class Test::Unit::TestCase
  FakeWeb.allow_net_connect = false

  def setup
    # omit OAuth2 authorization for tests
    AdwordsApi::Api.any_instance.stubs(:authorize).returns(nil)
  end

  # many integration tests need to use campaign or ad group
  # instead of creating them in every test, we do it here  
  #
  @@bare_campaign_id = nil
  @@bare_ad_group_id = nil

  def create_bare_campaign!(force = false)
    if force or @@bare_campaign_id.nil?
      campaign = Adapi::Campaign.create(
        name: "Campaign #%d" % (Time.new.to_f * 1000).to_i,
        status: 'PAUSED',
        bidding_strategy: { 
          xsi_type: 'BudgetOptimizer', 
          bid_ceiling: 20 
        },
        budget: 50
      )

      if campaign.errors.any?
        raise "CANNOT CREATE BARE CAMPAIGN (during test initialization):\n" + campaign.errors.join("\n")
      end

      @@bare_campaign_id = campaign[:id]
    end

    @@bare_campaign_id
  end

  def create_bare_ad_group!(force = false)
    if force or @@bare_ad_group_id.nil?
      @@bare_campaign_id ||= create_bare_campaign!(true)

      ad_group = Adapi::AdGroup.create(
        campaign_id: @@bare_campaign_id,
        name: "AdGroup #%d" % (Time.new.to_f * 1000).to_i,
        status: 'ENABLED'
      )

      if ad_group.errors.any?
        raise "CANNOT CREATE BARE AD GROUP (during test initialization):\n" + ad_group.errors.join("\n")
      end

      @@bare_ad_group_id = ad_group[:id]
    end

    @@bare_ad_group_id
  end

end
