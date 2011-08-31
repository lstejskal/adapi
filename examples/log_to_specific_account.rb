
require 'adapi'

Adapi::Config.load_settings(
  :path => File.expand_path(File.dirname(__FILE__)),
  :filename => 'custom_settings.yml'
)

Adapi::Config.set(:sandbox)

require 'pp'
pp Adapi::Config.read

=begin
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
=end

# create campaign
require 'add_bare_campaign'
