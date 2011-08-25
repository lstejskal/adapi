
require 'adapi'

# add campaign with basic data only

campaign_data = {
  :name => "Ataxo Campaign #%d" % (Time.new.to_f * 1000).to_i,
  :status => 'PAUSED',
  :bidding_strategy => { :xsi_type => 'ManualCPC' },
  :budget => {
    :period => 'DAILY',
    :amount => { :micro_amount => 50000000 },
    :delivery_method => 'STANDARD'
  },

  # Set the campaign network options to Search and Search Network.
  :network_setting => {
    :target_google_search => true,
    :target_search_network => true,
    :target_content_network => false,
    :target_content_contextual => false
  }
}

# use specific config data

Adapi::Config.set( {
  :authentication => {
    :method => 'ClientLogin',
    :developer_token => 'DEVELOPER_TOKEN',
    :auth_token => 'AUTH_TOKEN',
    :user_agent => 'Adapi Examples',
    :email => 'EMAIL',
    :password => 'PASSWORD',
    :client_email => 'client@email.com'
  },
  :service => {
    :environment => 'SANDBOX' # 'PRODUCTION'
  }
})

p Adapi::Campaign.new(:data => campaign_data).create
