# encoding: utf-8

module Adapi
  VERSION = "0.1.3"

  # CHANGELOG:
  #
  # 0.1.3
  # added ManagedAccount service
  # added BudgetOrder service
  #
  # 0.1.2
  # fixed bug in campaign.update
  #
  # 0.1.1
  # fixed bug in campaign.budget settings
  #
  # 0.1.0
  # updated to AdWords API version v201206
  # updated gem dependencies (including google-adwords-api to 0.7.0)
  # improved and debugged error handling for complex create/update methods
  # optimized batch creating of ads
  #
  # 0.0.9
  # added Campaign#update method - updates campaign, criteria and ad groups by a single method call
  # fixed PolicyViolation exemptions for keywords and ads
  # fixed and refactored error handling for most models
  # refactored AdWords model attributes structure, simplify the code
  # update find methods for most models to display all attributes
  # updated gem dependencies (i.e. google-adwords-api to 0.6.2)
  # refactor SOAP logging - get rid of monkeypatch
  #
  # 0.0.8
  # updated to AdWords API version v201109_1
  # updated gem dependencies
  # removed obsolete monkeypatches
  # improved SOAP logging - enable pretty logging and configurable log path
  # added conversion of legacy province_code to province_name in location search
  # added tests for Campaign, CampaignCriterion and Location service
  # added Getting Started section to README
  #
  # 0.0.7
  # fix Location search by country code
  # hotfix OAuth
  #
  # 0.0.6
  # updated to latest adwords-api and ads-common gems, which fix many issues with AdWords API version v201109
  # fix CampaignCriterion service
  # fix examples
  #
  # 0.0.5
  # converted to AdWords API version v201109
  #   moved from CampaignTarget to CampaignCriterion
  #   implemented Location and Language finders
  # started writing integration tests
  # added logging of SOAP requests
  #
  # 0.0.4
  # changed README to markdown format
  # updated DSL for creating campaign and campaign target
  # implemented find methods for campaigns and ad groups
  # implemented getting complete campaigns (in one hash with targets, ad groups, keywords and ads)
  #
  # 0.0.3
  # converted to ActiveModel
  # moved common functionality to Api class
  # changed http client to curb and hotfix ssl authentication bug in HTTPI
  # added basic error handling
  # changed DSL for Campaign attributes
  # changed Ad model to general Ad model and moved TextAd to separate model
  # added support for more target types and changed DSL for CampaignTarget
  # converted to Ruby 1.9.2 (should work in Ruby 1.8.7 as well)
  #
  # 0.0.2
  # [FIX] switched google gem dependencies from edge to stable release
end
