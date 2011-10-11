# encoding: utf-8

module Adapi
  # Ad::TextAd == AdGroupAd::TextAd
  #
  # http://code.google.com/apis/adwords/docs/reference/latest/AdGroupAdService.TextAd.html
  #
  class Ad::TextAd < Ad

    attr_accessor :headline, :description1, :description2

    def attributes
      super.merge('headline' => headline, 'description1' => description1, 'description2' => description2)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupAdService

      @xsi_type = 'TextAd'

      %w{ headline description1 description2 }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def save
      self.new? ? self.create : self.update
    end
 
    def create
      operation = {
        :operator => 'ADD',
        :operand => {
          :ad_group_id => @ad_group_id,
          :status => @status,
          :ad => self.data
        }
      }

      response = self.mutate(operation)
 
      # check for PolicyViolationError(s)
      # PS: check google-adwords-api/examples/handle_policy_violation_error.rb
      if (self.errors['PolicyViolationError'].size > 0)
        # set exemptions and try again
        operation[:exemption_requests] = errors['PolicyViolationError'].map do |error|
          { :key => error }
        end

        self.errors.clear

        response = self.mutate(operation)  
      end

      return false unless (response and response[:value])
  
      self.id = response[:value].first[:ad][:id] rescue nil
  
      true
    end

    # params - specify hash of params and values to update
    # PS: I think it's possible to edit only status, but not headline,
    # descriptions... instead you should delete existing ad and create a new one
    #
    def update(params = {})
      # set params (:status param makes it a little complicated)
      #
      updated_params = (params || self.attributes).symbolize_keys
      updated_status = updated_params.delete(:status)
      
      response = self.mutate(
        :operator => 'SET', 
        :operand => {
          :ad_group_id => self.ad_group_id,
          :ad => updated_params.merge(:id => self.id),
          :status => updated_status
        }
      )

      (response and response[:value]) ? true : false
    end

    def find # == refresh
      TextAd.find(:first, :ad_group_id => self.ad_group_id, :id => self.id)
    end

    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      # for ActiveRecord compatibility, we don't use anything besides conditions
      # params for now
      params = params[:conditions] if params[:conditions]

      # we need ad_group_id
      raise ArgumentError, "AdGroup ID is required" unless params[:ad_group_id]
 
      # supported condition parameters: ad_group_id and id
      predicates = [ :ad_group_id, :id ].map do |param_name|
        if params[param_name]
          {:field => param_name.to_s.camelcase, :operator => 'EQUALS', :values => params[param_name] }
        end
      end.compact

      selector = {
        :fields => ['Id', 'Headline'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }

      response = TextAd.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      response.map! do |data|
        TextAd.new(data[:ad].merge(:ad_group_id => data[:ad_group_id], :status => data[:status]))
      end

      # TODO convert to TextAd instances
      # PS: we already have ad_group_id parameter
      first_only ? response.first : response
    end

  end
end
