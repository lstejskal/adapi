# encoding: utf-8

require 'adapi'

# create campaign
require_relative 'add_bare_campaign'

$campaign_criterion = Adapi::CampaignCriterion.new(
  :campaign_id => $campaign[:id],
  :negative => true,
  :criteria => {
    :language => %w{ de },

    :location => { 
      :name => { :city => 'Oslo' }
    }
  }
)

$campaign_criterion.create

p $campaign_criterion.attributes

