module Adapi
  class Api

    attr_accessor :adwords, :service, :version, :params

    def initialize(params = {})
      raise "Missing Service Name" unless params[:service_name]

      puts "\n\nEXISTING INSTANCE USED\n\n" if params[:adwords_api_instance]

      # if params[:api_login] in nil, default login data are used
      # from ~/adwords_api.yml
      @adwords = params[:adwords_api_instance] || AdwordsApi::Api.new(Adapi::Config.read)
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
      @params = params
    end

  end
end
