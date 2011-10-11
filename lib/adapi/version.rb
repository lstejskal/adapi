# encoding: utf-8

module Adapi
  VERSION = "0.0.3"

  # CHANGELOG:
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
