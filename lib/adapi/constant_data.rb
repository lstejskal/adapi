# encoding: utf-8

module Adapi
  class ConstantData < Api

    def initialize(params = {})
      params[:service_name] = :ConstantDataService

      super(params)
    end

  end
end
