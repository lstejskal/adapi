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
    #:criterion=>{:id=>105790288, :type=>"KEYWORD", :criterion_type=>"Keyword", :text=>"systemtelefon", :match_type=>"PHRASE", :xsi_type=>"Keyword"}
    attr_accessor :criterion_id, :criterion_type, :criterion_type, :criterion_text, :criterion_match_type, :criterion_xsi_type
    #:ad_group_criterion_type=>"BiddableAdGroupCriterion",
    attr_accessor :ad_group_criterion_type
    #:stats=>{:network=>"SEARCH", :stats_type=>"Stats"},
    attr_accessor :stats_network, :stats_type
    #=> {:text=>{:ad_group_id=>1658215692, :criterion_use=>"BIDDABLE", :ad_group_criterion_type=>"BiddableAdGroupCriterion",  :xsi_type=>"BiddableAdGroupCriterion"}, :match_type=>"BROAD", :negative=>false}
    attr_accessor :type, :criterion_use, :ad_group_criterion_type, :xsi_type, :match_type, :negative

    def attributes
      super.merge(serializable_hash)
    end

    def initialize( ext_options = {} )
      options       = default_options.merge(ext_options.delete_if{|k,v|v.nil?})

      # I think this is just not necessary and maybe restricting later on
      #%w{ keywords }.each do |param_name|
      #  self.send "#{param_name}=", params[param_name.to_sym]
      #end

      self.type                           = options[:type],
      self.match_type                     = options[:match_type],
      self.negative                       = options[:negative],
      self.ad_group_id                    = options[:ad_group_id],
      self.criterion_use                  = options[:criterion_use],
      self.ad_group_criterion_type        = options[:ad_group_criterion_type],
      self.xsi_type                       = options[:xsi_type],
      self.id                             = options[:id],
      self.criterion_type                 = options[:type],
      self.criterion_text                 = options[:text],
      self.criterion_match_type           = options[:match_type],
      self.criterion_xsi_type             = options[:xsi_type],
      self.stats_network                  = options[:network],
      self.stats_type                     = options[:stats_type]

      #self.keywords ||= []
      #self.keywords.map! { |k| Keyword.keyword_attributes(k) }

      super(params)
    end

    def default_options
      {
        :service_name   => :AdGroupCriterionService,
        :xsi_type       => 'AdGroupCriterion'
      }
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
      operations = [
        {
          :operator => 'ADD', 
          :operand => {
            :xsi_type => (negative ? 'NegativeAdGroupCriterion' : 'BiddableAdGroupCriterion'),
            :ad_group_id => ad_group_id,
            :criterion => {
              :xsi_type => 'Keyword',
              :text => criterion_text,
              :match_type => criterion_match_type
            }
          }
        }
      ]

      response = self.mutate(operations)

      return false unless (response and response[:value])
      
      self.keywords = response[:value].map { |keyword| keyword[:criterion] }

      true
    end

    def serializable_hash
      {
        :type                           => type,
        :match_type                     => match_type,
        :negative                       => negative,
        :ad_group_id                    => ad_group_id,
        :criterion_use                  => criterion_use,
        :ad_group_criterion_type        => ad_group_criterion_type,
        :xsi_type                       => xsi_type,
        :id                             => id,
        :criterion_type                 => type,
        :criterion_text                 => text,
        :criterion_match_type           => match_type,
        :criterion_xsi_type             => xsi_type,
        :stats_network                  => network,
        :stats_type                     => stats_type
      }
    end

    def self.find(ext_options = {})
      options       = default_find_options.merge(ext_options.delete_if{|k,v|v.nil?})

      # we need ad_group_id
      raise ArgumentError, "AdGroup ID is required" unless options[:ad_group_id]
 
      # supported condition parameters: ad_group_id and id
      predicates = [ :ad_group_id, :criterion_use ].map do |param_name|
        if ext_options[param_name]
          value = Array.try_convert(ext_options[param_name]) ? params_param_name : [options[param_name]]
          {:field => param_name.to_s.camelcase, :operator => 'IN', :values => value }
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

      #response = case options[:format].to_sym
      #  when :short
      #    Keyword.shortened(response)
      #  when :params
      #    Keyword.parameterized(response)
      #  else
      #    response
      #end

      keywords = []

      response.each do |r|
        keywords << create_from_api(r)
      end

      keywords
    end
    
    def self.default_find_options
      {
        :format   => :google,
        :amount   => :all
      }
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

    def self.create_from_api( entry )
      raise Exception.new("Unsupported type #{entry.keys.first}") unless entry.key?(:text)

      type  = :text
      e     = entry[type]
      c     = entry[type][:criterion]
      s     = entry[type][:stats]

      Keyword.new(
        :type                           => :type,
        :match_type                     => entry[:match_type],
        :negative                       => entry[:negative],
        :ad_group_id                    => e[:ad_group_id],
        :criterion_use                  => e[:criterion_use],
        :ad_group_criterion_type        => e[:ad_group_criterion_type],
        :xsi_type                       => e[:xsi_type],
        :id                             => c[:id],
        :criterion_type                 => c[:type],
        :criterion_text                 => c[:text],
        :criterion_match_type           => c[:match_type],
        :criterion_xsi_type             => c[:xsi_type],
        :stats_network                  => s[:network],
        :stats_type                     => s[:stats_type]
      )
    end
  end
end
