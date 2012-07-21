# encoding: utf-8

# Basic adapi class, parent of all service classes

module Adapi
  class Api
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    LOGGER = Config.setup_logger

    API_EXCEPTIONS = [
      AdsCommon::Errors::ApiException, 
      AdsCommon::Errors::HttpError, 
      AdwordsApi::Errors::ApiException
    ]

    attr_accessor :adwords, :service, :version, :params,
      :id, :status, :xsi_type

    # Returns hash of attributes for a model instance
    #
    # This is an implementation of ActiveRecord::Base#attributes method.
    # Children of API model customize this method for their own attributes.
    #
    def attributes
      { 'status' => status, 'xsi_type' => xsi_type }
    end

    def initialize(params = {})
      params.symbolize_keys!

      raise "Missing Service Name" unless params[:service_name]

      # if params[:api_login] in nil, default login data are used
      # from ~/adwords_api.yml
      @adwords = params[:adwords_api_instance] || AdwordsApi::Api.new(Adapi::Config.read)
      @adwords.logger = LOGGER if LOGGER
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
      @params = params
    end

    def to_param
      self[:id]
    end

    def persisted?
      false
    end

    # FIXME hotfix, should be able to sort it out better through ActiveModel
    def [](k)
      self.send(k)
    end

    def []=(k,v)
      self.send("#{k}=", v)
    end

    alias :to_hash :attributes

    # detects whether the instance has been saved already
    #
    def new?
      self.id.blank?
    end

    def self.create(params = {})
      # FIXME deep symbolize_keys, probably through ActiveSupport
      params.symbolize_keys!

      api_instance = self.new(params)
      api_instance.create
      api_instance
    end

    # done mostly for campaign, probably won't work pretty much anywhere else
    # which can be easily fixed creating by self.update method for specific
    # class
    #
    def self.update(params = {})
      params.symbolize_keys!

      # PS: updating campaign without finding it is much faster
      api_instance = self.new()
      api_instance.id = params.delete(:id)
      api_instance.errors.add('id', 'is missing') unless api_instance.id
      
      api_instance.update(params)
      api_instance
    end


    # wrap AdWords add/update/destroy actions and deals with errors
    # PS: Keyword and Ad models have their own wrappers because of
    # PolicyViolations
    #
    def mutate(operation)      
      operation = [operation] unless operation.is_a?(Array)
      
      # fix to save space during specifyng operations
      operation = operation.map do |op|
        op[:operand].delete(:status) if op[:operand][:status].nil?
        op
      end
      
      begin    
        response = @service.mutate(operation)

      rescue *API_EXCEPTIONS => e
        # TODO probably obsolete. keep or remove?
        # error_key = self.xsi_type.to_s.underscore rescue :base
        # self.errors.add(error_key, e.message)

        self.errors.add(:base, e.message)
      end
      
      response
    end

    # convert number to micro units (unit * one million)
    #
    def self.to_micro_units(x)
      (x.to_f * 1e6).to_i
    end

  end
end
