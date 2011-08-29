
require 'adapi'

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

# create campaign
require 'add_bare_campaign'
