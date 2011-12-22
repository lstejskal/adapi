# encoding: utf-8

# TODO user should be able to delete keywords
# TODO user should not see deleted keywords by default
#
# TODO program should be able to detect keywords in shortened or Google form
# automatically on input (outsource into separate method?)
#
# TODO user should be able to enter keywords in both shortened, parameterized and Google form
# 
# FIXME broken Keyword.negative param 

# Currently the Keyword DSL is a mess. There are basically three forms:
# * ultra short form on input: keyword example
# * shortened form: {:text=>"keyword example", :match_type=>"BROAD", :negative=>false} 
# * google form

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

    # Converts keyword specification from shortened form to Google format
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

      # sets whether keyword is negative or not
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
      params[:format] ||= :google # default, don't do anything with the data from google
      
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

# for now, always return keywords in :google format
=begin
      response = case params[:format].to_sym
      when :short
        Keyword.shortened(response)
      when :params
        Keyword.parameterized(response)
      else
        response
      end
=end

      Keyword.new(
        :ad_group_id => params[:ad_group_id],
        :keywords => response
      )
    end

    # PS: create a better UI for this?
    # Keyword.convert(:to => :params, :source => $google_keywords)
    # and Keyword.parametrized($google_keywords) just calling that?

    # Converts list of keywords from Google format to short format
    #
    def self.shortened(google_keywords = [])
      self.parameterized(google_keywords).map do |keyword|
        keyword[:text] = "-%s" % keyword[:text] if keyword[:negative]
        
        case keyword[:match_type]
        when 'PHRASE'
          "\"%s\"" % keyword[:text]
        when 'EXACT'
          "[%s]" % keyword[:text]
        else # 'BROAD'
          keyword[:text]
        end
      end
    end

    # Converts list of keywords from Google format to params format
    # (the way it can be entered into Keywords model)
    # 
    def self.parameterized(google_keywords = [])
      google_keywords.map do |keyword|        
        kw = keyword[:text][:criterion]
        
        {
          :text => kw[:text],
          :match_type => kw[:match_type],
          :negative => (keyword[:text][:xsi_type] == "NegativeAdGroupCriterion")
        }
      end
    end

  end
end
