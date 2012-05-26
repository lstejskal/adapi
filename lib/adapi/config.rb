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

    DEFAULT_LOG_PATH = File.join(ENV['HOME'], 'adapi.log')

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

    # Loads adapi configuration from given hash or from external configuration
    # file
    #
    # params:
    # * dir (default: HOME)
    # * filename (default: adapi.yml)
    # * in_hash - hash to use instead of external configuration
    #
    def self.load_settings(params = {})
      if params[:in_hash]
        return @settings = params[:in_hash]
      end

      # load external config file (defaults to ~/adapi.yml)
      self.dir = params[:dir] if params[:dir]
      self.filename = params[:filename] if params[:filename]
      path = (self.dir.present? ? File.join(self.dir, self.filename) : self.filename)

      if File.exists?(path)
        @settings = YAML::load(File.read(path)) rescue {}
        @settings.symbolize_keys!

        # is it an adwords_api config-file?
        if @settings.present? && @settings[:authentication].present?
          @settings = {:default => @settings}
        end
      end

      @settings
    end

    # Returns complete path to log file - both directory and file name.
    #
    def self.log_path
      (Adapi::Config.read[:library][:log_path] rescue nil) || DEFAULT_LOG_PATH 
    end

    # Returns freshly initialized logger object (or nil, if not available)
    #
    def self.setup_logger
      log_level = self.read[:library][:log_level] rescue nil

      if log_level
        logger = Logger.new(self.log_path)
        logger.level = eval("Logger::%s" % log_level.to_s.upcase)
        logger
      else
        nil
      end
    end
    
  end
end
