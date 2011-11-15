# encoding: utf-8

module Adapi
  class AdGroup < Api
  
    attr_accessor :campaign_id, :name, :bids, :keywords, :ads

    validates_presence_of :campaign_id, :name, :status
    validates_inclusion_of :status, :in => %w{ ENABLED PAUSED DELETED }

    def attributes
      super.merge('campaign_id' => campaign_id, 'name' => name, 'bids' => bids)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupService

      @xsi_type = 'AdGroup'

      %w{ campaign_id name status bids keywords ads }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      # convert bids to GoogleApi format
      #
      # can be either string (just xsi_type) or hash (xsi_type with params)
      # althogh I'm not sure if just string makes sense in this case
      #
      if @bids
        unless @bids.is_a?(Hash)
          @bids = { :xsi_type => @bids }
        end
  
        if @bids[:keyword_max_cpc] and not @bids[:keyword_max_cpc].is_a?(Hash)
          @bids[:keyword_max_cpc] = {
            :amount => {
              :micro_amount => Api.to_micro_units(@bids[:keyword_max_cpc])
            }
          }
        end
      end

      @keywords ||= []
      @ads ||= []

      super(params)
    end

    def create
      return false unless self.valid?
      
      operand = Hash[
        [:campaign_id, :name, :status, :bids].map do |k|
          [ k.to_sym, self.send(k) ] if self.send(k)
        end.compact
      ]

      response = self.mutate(
        :operator => 'ADD', 
        :operand => operand
      )

      return false unless (response and response[:value])
      
      self.id = response[:value].first[:id] rescue nil
      
      if @keywords.size > 0
        keyword = Adapi::Keyword.create(
          :ad_group_id => @id,
          :keywords => @keywords
        )
        
        if (keyword.errors.size > 0)
          self.errors.add("[keyword]", keyword.errors.to_a)
          return false 
        end
      end

      @ads.each do |ad_data|
        ad = Adapi::Ad::TextAd.create( ad_data.merge(:ad_group_id => @id) )

        if (ad.errors.size > 0)
          self.errors.add("[ad] \"#{ad.headline}\"", ad.errors.to_a)
          return false 
        end
      end

      true
    end
 
    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      raise "No Campaign ID is required" unless params[:campaign_id]

      predicates = [ :campaign_id, :id ].map do |param_name|
        if params[param_name]
          {:field => param_name.to_s.camelcase, :operator => 'EQUALS', :values => params[param_name] }
        end
      end.compact

      selector = {
        :fields => ['Id', 'Name', 'Status'],
        :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }

      response = AdGroup.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      #response.map! do |data|
      #  TextAd.new(data[:ad].merge(:ad_group_id => data[:ad_group_id], :status => data[:status]))
      #end

      first_only ? response.first : response
    end

    def find_keywords(first_only = false)
      Keyword.find( (first_only ? :first : :all), :ad_group_id => self.id )
    end

    def find_ads(first_only = false)
      Ad::TextAd.find( (first_only ? :first : :all), :ad_group_id => self.id )
    end

  end
end
