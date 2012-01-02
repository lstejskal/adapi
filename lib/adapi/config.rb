# encoding: utf-8

# PS: what about this config setting?
# Campaign.create(:data => campaign_data, :account => :my_account_alias)

module Adapi
  class Config
    class << self
      attr_accessor :adapi_dir, :adapi_file, :adwords_api_dir, :adwords_api_file
    end

    self.adapi_dir         = ENV['HOME']
    self.adapi_file        = 'adapi.yml'
    self.adwords_api_dir   = ENV['HOME']
    self.adwords_api_file  = 'adwords_api.yml'


    # display hash of all account settings
    #
    def self.settings
      @settings ||= self.load_settings
    end

    # display actual account settings
    # if it's not available, set to :default account settings
    #
    def self.read # = @data
      @data ||= self.settings[:default]
    end

    # account_alias - alias of an account set in settings
    # authentication_params - ...which we want to override
    #
    def self.set(account_alias = :default, authentication_params = {})
      custom_settings = @settings[account_alias.to_sym]
      custom_settings[:authentication] = custom_settings[:authentication].merge(authentication_params)
      @data = custom_settings

=begin original method, to be merged into the new one
      # hash of params - default
      if params.is_a?(Hash)
        @data = params
      # set alias from adapi.yml
      elsif params.is_a?(Symbol)
        @data = @settings[params]
      end
=end
    end

    # params:
    # * path - default: user's home directory
    # * filename - default: adapi.yml
    # TODO: set to HOME/adwords_api as default
    def self.load_settings(params = {})
      params[:in_hash] ||= nil

      # HOTFIX enable load by hash
      if params[:in_hash]
        @settings = params[:in_hash]
        return @settings
      end

      adapi_path = adapi_dir.present? ? File.join(adapi_dir, adapi_file) : adapi_file
      puts adapi_path
      adwords_api_path = adwords_api_path.present? ? File.join(adwords_api_dir, adwords_api_file) : adwords_api_file

      if File.exists?(adapi_path)
        @settings = YAML::load(File.read(adapi_path)) rescue {}
      elsif File.exists?(adwords_api_path)
        @settings = { :default => YAML::load(File.read(adwords_api_path)) } rescue {}
      end

      @settings
    end

  end
end
