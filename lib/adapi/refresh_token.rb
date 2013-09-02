# encoding: utf-8

module Adapi

  module RefreshToken
    def self.token_cache
      @token_cache ||= {}
    end

    def self.get_access_token access
      auth = access[:authentication]

      unless token_cache.has_key?(auth[:oauth2_refresh_token]) && token_cache[auth[:oauth2_refresh_token]][:expire_at] > Time.now
        oauth_options = {
          :authorization_uri =>
            'https://accounts.google.com/o/oauth2/auth',
          :token_credential_uri =>
            'https://accounts.google.com/o/oauth2/token',
          :client_id => auth[:oauth2_client_id],
          :client_secret => auth[:oauth2_client_secret],
          :scope => "https://adwords.google.com/api/adwords/",
          :refresh_token => auth[:oauth2_refresh_token]
        }
        client = Signet::OAuth2::Client.new(oauth_options)
        token_cache[auth[:oauth2_refresh_token]] = {
          :token =>  client.refresh!,
          :expire_at => Time.now + 3000,
        }
      end
      access[:authentication][:oauth2_token] = token_cache[auth[:oauth2_refresh_token]][:token]

      token_cache[auth[:oauth2_refresh_token]][:token]
    end
  end
end