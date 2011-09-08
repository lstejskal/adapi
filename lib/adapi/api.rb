module Adapi
  class Api
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    # TODO include ActiveModel::Dirty

    attr_accessor :adwords, :service, :version, :params

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

  end
end
