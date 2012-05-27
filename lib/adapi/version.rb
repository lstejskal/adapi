# encoding: utf-8

module Adapi
  VERSION = "0.0.8"

  # CHANGELOG:
  #
  # 0.0.8
  # updated to AdWords API version v201109
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
