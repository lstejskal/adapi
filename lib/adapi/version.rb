# encoding: utf-8

module Adapi
  VERSION = "0.2.0"

  # CHANGELOG:
  #
  # 0.2.0
  # updated to AdWords API version v201209
  # switched authentication to OAuth2
  # updated README
  # updated tests and examples 
  # removed compatibility of config setting with adwords-api
  #
  # 0.1.5
  # updated gems - second try to fix the "bundle install" infinite loop
  #
  # 0.1.4
  # updated gems (which fixed the "bundle install" infinite loop) 
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
end
