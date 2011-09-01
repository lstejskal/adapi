
require 'adapi'

# use specific config data
Adapi::Config.set({
  :authentication => {
    :method => 'ClientLogin',
    :email => 'sandbox_email@gmail.com',
    :password => 'sandbox_password',
    :developer_token => 'sandbox_developer_token',
    :client_email => 'sandbox_client_email@gmail.com',
    :user_agent => 'Adwords API Test'
  },
  :service => {
    :environment => 'SANDBOX'
  }
})

# create campaign
require 'add_bare_campaign'
