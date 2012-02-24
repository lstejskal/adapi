# encoding: utf-8

# This class hold configuration data for AdWords API

# TODO enable this way of using configuration
# Adapi::Campaign.create(:data => campaign_data, :account => :my_account_alias)

module Adapi
  class Config
    class << self
      attr_accessor :dir, :filename
    end

    self.dir = ENV['HOME']
    self.filename = 'adapi.yml'

    # display hash of all account settings
    #
    def self.settings(reload = false)
      if reload
        @settings = self.load_settings
      else
        @settings ||= self.load_settings
      end
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

      path = dir.present? ? File.join(dir, filename) : filename

      if File.exists?(path)
        @settings = YAML::load(File.read(path)) rescue {}
        @settings.symbolize_keys!

        if @settings.present?
          # is it an adwords_api config-file?
          if @settings[:authentication].present?
            @settings = {:default => @settings}
          end
        end
      end

      @settings
    end
  end
end
