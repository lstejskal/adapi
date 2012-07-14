# encoding: utf-8

require 'adapi'

Adapi::Config.load_settings(:in_hash => {
  :coca_cola => {
    :authentication => {
      :method => 'ClientLogin',
      :email => 'coca_cola_email@gmail.com',
      :password => 'coca_cola_password',
      :developer_token => 'coca_cola_developer_token',
      :user_agent => 'Coca-Cola Adwords API Test'
    },
    :service => {
      :environment => 'SANDBOX'
    }
  },
 :pepsi => {
    :authentication => {
      :method => 'ClientLogin',
      :email => 'pepsi_email@gmail.com',
      :password => 'pepsi_password',
      :developer_token => 'pepsi_developer_token',
      :user_agent => 'Pepsi Adwords API Test'
    },
    :service => {
      :environment => 'SANDBOX'
    }
  }
})

Adapi::Config.set(:pepsi, :client_customer_id => '555-666-7777')

p Adapi::Config.read
