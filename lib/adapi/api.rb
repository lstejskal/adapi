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

      puts "\n\nEXISTING INSTANCE USED\n\n" if params[:adwords_api_instance]

      # if params[:api_login] in nil, default login data are used
      # from ~/adwords_api.yml
      @adwords = params[:adwords_api_instance] || AdwordsApi::Api.new(Adapi::Config.read)
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
      @params = params
    end

    def persisted?
      false
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

    # wrap AdWords add/update/destroy actions and deals with errors
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
