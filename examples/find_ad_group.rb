# encoding: utf-8

require 'adapi'

require_relative 'add_bare_ad_group'

$ad_group = Adapi::AdGroup.find(:first, :campaign_id => $ad_group.campaign_id)

pp "\nAD GROUP DATA:"
pp $ad_group.attributes
