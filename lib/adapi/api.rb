module Adapi
  class Api

    attr_accessor :adwords, :service, :version

    def initialize(params = {})
      raise "Missing Service Name" unless params[:service_name]

      @adwords = AdwordsApi::Api.new
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
    end

  end
end
