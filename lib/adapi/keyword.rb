# encoding: utf-8

module Adapi
  class Keyword < AdGroupCriterion

    attr_accessor :keywords

    def attributes
      super.merge('keywords' => keywords)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupCriterionService

      @xsi_type = 'AdGroupCriterion'

      %w{ keywords }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      self.keywords ||= []
      self.keywords.map! { |k| Keyword.keyword_attributes(k) }

      super(params)
    end

    # TODO include formatting in create method
    #
    def self.keyword_attributes(keyword)
      # detect match type
      match_type = case keyword[0]
        when '"'
          keyword = keyword.slice(1, (keyword.size - 2))
          'PHRASE'
        when '['
          keyword = keyword.slice(1, (keyword.size - 2))
          'EXACT'
        else
          'BROAD'
      end

      # detect if keyword is negative
      negative = if (keyword =~ /^\-/)
        keyword.slice!(0, 1)
        true
      else
        false
      end

      { :text => keyword, :match_type => match_type, :negative => negative }
    end

    def create
      operations = @keywords.map do |keyword|
        {
          :operator => 'ADD', 
          :operand => {
            :xsi_type => (keyword[:negative] ? 'NegativeAdGroupCriterion' : 'BiddableAdGroupCriterion'),
            :ad_group_id => @ad_group_id,
            :criterion => {
              :xsi_type => 'Keyword',
              :text => keyword[:text],
              :match_type => keyword[:match_type]
            }
          }
        }
      end

      response = self.mutate(operations)

      return false unless (response and response[:value])
      
      self.keywords = response[:value].map { |keyword| keyword[:criterion] }

      true
    end

    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      # this has no effect, it's here just to have the same interface everywhere
      first_only = (amount.to_sym == :first)

      # we need ad_group_id
      raise ArgumentError, "AdGroup ID is required" unless params[:ad_group_id]
 
      # supported condition parameters: ad_group_id and id
      predicates = [ :ad_group_id ].map do |param_name|
        if params[param_name]
          {:field => param_name.to_s.camelcase, :operator => 'EQUALS', :values => params[param_name] }
        end
      end.compact

      # Get all the criteria for this ad group.
      selector = {
        :fields => ['Id', 'Text'],
        :ordering => [{ :field => 'AdGroupId', :sort_order => 'ASCENDING' }],
        :predicates => predicates
      }

      response = Keyword.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      Keyword.new(
        :ad_group_id => params[:ad_group_id],
        :keywords => response.map { |keyword| keyword[:criterion] }
      )
    end

  end
end
