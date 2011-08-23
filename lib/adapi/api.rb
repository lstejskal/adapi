module Adapi
  class Api

    attr_accessor :adwords, :service, :version

=begin

== Authentication

Default login data are loaded from ~/adwords_api.yml

However, you can set custom login data in :adword_api param. Example:

:adwords_api => {
  :authentication => {
      :method => 'ClientLogin',
      :developer_token => 'DEVELOPER_TOKEN',
      :user_agent => 'Ruby Sample',
      :password => 'PASSWORD',
      :email => 'user@domain.com',
      :client_email => 'user2@domain.com'
  },
  :service => {
    :environment => 'PRODUCTION'
  }
}

TODO should support aliases. :adwords_api => { :alias => 'mediatel' }
# should find specific authentication data. but where to store them?
# set location for YAML file?

TODO eventually we should create some authentication service which
will store accounts data and return only tokens to us (not passwords)

=end

    def initialize(params = {})
      raise "Missing Service Name" unless params[:service_name]

      # if params[:api_login] in nil, default login data are used
      # from ~/adwords_api.yml
      @adwords = AdwordsApi::Api.new(params[:adwords_api])
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
    end

  end
end
