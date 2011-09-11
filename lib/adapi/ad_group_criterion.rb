module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/AdGroupCriterionService.html
  #
  class AdGroupCriterion < Api

    attr_accessor :ad_group_id, :criterion_use

    def attributes
      super.merge('ad_group_id' => ad_group_id)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupCriterionService

      @xsi_type = 'AdGroupCriterion'

      %w{ ad_group_id criterion_use }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

  end
end
