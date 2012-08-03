# encoding: utf-8

module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/AdGroupCriterionService.html
  #
  class AdGroupCriterion < Api

    ATTRIBUTES = [ :ad_group_id, :criterion_use ]

    attr_accessor *ATTRIBUTES 

    # FIXME why we don't use :criterion_use parameter here?
    def attributes
      super.merge( ad_group_id: ad_group_id )
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupCriterionService

      @xsi_type = 'AdGroupCriterion'

      ATTRIBUTES.each do |param_name|
        self.send "#{param_name}=", params[param_name]
      end

      super(params)
    end

    def delete(criterion_id)
      response = self.mutate(
        :operator => 'REMOVE',
        :operand => {
          :ad_group_id => self.ad_group_id,
          :criterion => { :id => criterion_id.to_i }
        }
      )

      (response and response[:value])
    end

  end
end
