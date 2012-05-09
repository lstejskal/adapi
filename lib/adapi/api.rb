# encoding: utf-8

module Adapi
  class Api
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    # TODO include ActiveModel::Dirty

    attr_accessor :adwords, :service, :version, :params,
      :id, :status, :xsi_type

    def attributes
      { 'status' => status, 'xsi_type' => xsi_type }
    end

    def initialize(params = {})
      params.symbolize_keys!

      raise "Missing Service Name" unless params[:service_name]

      # if params[:api_login] in nil, default login data are used
      # from ~/adwords_api.yml
      @adwords = params[:adwords_api_instance] || AdwordsApi::Api.new(Adapi::Config.read)
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
      @params = params

      log_level = Adapi::Config.read[:library][:log_level] rescue nil
      if log_level
        logger = Logger.new( params[:log_path] || Adapi::Config.log_path )
        logger.level = eval("Logger::%s" % log_level.to_s.upcase)
        @adwords.logger = logger
      end
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

    # return parameters in hash
    # filtered for API calls by default: without :id and :status parameters
    # PS: attributes method always returns all specified attributes
    #
    def data(filtered = true)
      data_hash = self.serializable_hash.symbolize_keys
      
      if filtered
        data_hash.delete(:id)
        data_hash.delete(:status)
      end
      
      data_hash
    end

    # alias to instance method: data
    # 
    alias :to_hash :data

    # detects whether the instance has been saved already
    #
    def new?
      self.id.blank?
    end

    def self.create(params = {})
      api_instance = self.new(params)
      api_instance.create
      api_instance
    end

    # done mostly for campaign, probably won't work pretty much anywhere else
    # which can be easily fixed creating by self.update method for specific
    # class
    #
    def self.update(params = {})
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
    
      rescue AdsCommon::Errors::HttpError => e
        self.errors.add(:base, e.message)

      # traps any exceptions raised by AdWords API
      rescue AdwordsApi::Errors::ApiException => e
        error_key = "[#{self.xsi_type.underscore}]"
  
        self.errors.add(error_key, e.message)
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
