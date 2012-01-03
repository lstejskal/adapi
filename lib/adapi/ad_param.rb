# encoding: utf-8

module Adapi
  class AdParam < Api
    attr_accessor :ad_group_id, :criterion_id, :insertion_text, :param_index

    validates_presence_of :ad_group_id, :criterion_id

    def attributes
      super.merge(
        'ad_group_id' => ad_group_id, 'criterion_id' => criterion_id,
        'insertion_text' => insertion_text, 'param_index' => param_index
      )
    end

    def initialize(params = {})
      params[:service_name] = :AdParamService

      %w{ ad_group_id criterion_id insertion_text param_index }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def create
      operation = {
        :operator => 'SET',
        :operand => serializable_hash
      }

      begin
        response = @service.mutate([operation])

      #rescue AdsCommon::Errors::HttpError => e
        self.errors.add(:base, e.message)

      ## traps any exceptions raised by AdWords API
      #rescue AdwordsApi::Errors::ApiException => e
      #  # return PolicyViolations so they can be sent again
      #  e.errors.each do |error|
      #    if (error[:api_error_type] == 'PolicyViolationError') && error[:is_exemptable]
      #      self.errors.add(error[:api_error_type], error[:key])
      #    else
      #      # otherwise, just report the errors
      #      self.errors.add( "[#{self.xsi_type.underscore}]", "#{error[:error_string]} @ #{error[:field_path]}")
      #    end
      #  end
      end

      response
    end

    def self.find(params = {})
      params.symbolize_keys!

      predicates = [ :ad_group_id, :criterion_id ].map do |param_name|
        if params[param_name]
          value = Array.try_convert(params[param_name]) ? params_param_name : [params[param_name]]
          {:field => param_name.to_s.camelcase, :operator => 'IN', :values => value }
        end
      end.compact

      selector = {
        :fields => ['AdGroupId', 'CriterionId', 'InsertionText', 'ParamIndex'],
        :predicates => predicates
      }

      response = AdParam.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      response.map! do |ad_params_data|
        AdParam.new(ad_params_data)
      end

      response
    end

    def serializable_hash
      {
        :ad_group_id    => ad_group_id,
        :criterion_id   => criterion_id,
        :param_index    => param_index,
        :insertion_text => insertion_text
      }
    end
  end
end
