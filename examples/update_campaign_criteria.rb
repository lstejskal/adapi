# encoding: utf-8

require 'adapi'

require_relative 'add_campaign_criteria'

Adapi::CampaignCriterion.new(
  :campaign_id => $campaign[:id],
  :criteria => {
    :language => %w{ en cs},
  }
).destroy

Adapi::CampaignCriterion.new(
  :campaign_id => $campaign[:id],
  :criteria => {
    :language => %w{ sk },
  }
).create

$campaign_criterion = Adapi::CampaignCriterion.find( :campaign_id => $campaign[:id] )
pp $campaign_criterion
