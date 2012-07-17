# encoding: utf-8

require 'adapi'

require_relative 'add_campaign_criteria'

=begin this is an obsolete way to do this
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
=end

$new_criteria = Adapi::CampaignCriterion.new(
  :campaign_id => $campaign[:id],
  :criteria => {
    :language => %w{ sk },
  }
)

$result = $new_criteria.update!

$campaign_criterion = Adapi::CampaignCriterion.find( :campaign_id => $campaign[:id] )
pp $campaign_criterion
