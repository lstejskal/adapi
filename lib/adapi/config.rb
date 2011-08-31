
# TODO get rid of class variables

# what about this config setting?
# Campaign.create(:data => campaign_data, :account => :my_account_alias)

module Adapi
  class Config
    # all settings
    @@settings = {}
    # actual settings
    @@data = nil

    def self.read
      @@data ||= Config.load_settings[:default]
    end

    # TODO described in README, but should be documented here as well
    #
    def self.set(params = {})
      # hash of params - default
      if params.is_a?(Hash)
        @@data = params
      # set alias from adapi.yml
      elsif params.is_a?(Symbol)
        @@data = @@settings[params] || Config.load_settings[params]
      end
    end

    # params:
    # * path - default: user's home directory
    # * filename - default: adapi.yml
    # TODO: set to HOME/adwords_api as default
    def self.load_settings(params = {})
      params[:path] ||= ENV['HOME']
      params[:filename] ||= 'adapi.yml'

      adapi_path = File.join(params[:path], params[:filename])
      adwords_api_path = File.join(ENV['HOME'], 'adwords_api.yml')

      if File.exists?(adapi_path)
        @@settings = YAML::load(File.read(adapi_path)) rescue {}
      elsif File.exists?(adwords_api_path)
        @@settings = { :default => YAML::load(File.read(adwords_api_path)) } rescue {}
      end

      @@settings
    end

  end
end
