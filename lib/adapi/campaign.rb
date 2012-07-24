# encoding: utf-8

# Class for CampaignService
#
# https://developers.google.com/adwords/api/docs/reference/latest/CampaignService

module Adapi
  class Campaign < Api

    NETWORK_SETTING_KEYS = [ :target_google_search, :target_search_network, 
      :target_content_network, :target_content_contextual, :target_partner_search_network ]

    ATTRIBUTES = [ :name, :status, :serving_status, :start_date, :end_date, :budget,
      :bidding_strategy, :network_setting, :campaign_stats, :criteria, :ad_groups,
      :ad_serving_optimization_status ]

    attr_accessor *ATTRIBUTES

    def attributes
      super.merge Hash[ ATTRIBUTES.map { |k| [k, self.send(k)] } ]
    end

    alias to_hash attributes

    validates_presence_of :name, :status
    validates_inclusion_of :status, :in => %w{ ACTIVE DELETED PAUSED }

    def initialize(params = {})
      params.symbolize_keys!

      params[:service_name] = :CampaignService
      
      @xsi_type = 'Campaign'

      ATTRIBUTES.each do |param_name|
        self.send("#{param_name}=", params[param_name])
      end

      # HOTFIX backward compatibility with old field for criteria
      @criteria ||= params[:targets] || {}

      @ad_groups ||= []

      super(params)
    end

    def start_date=(a_date)
      @start_date = parse_date(a_date) if a_date.present?
    end

    def end_date=(a_date)
      @end_date = parse_date(a_date) if a_date.present?
    end

    def parse_date(a_date)
      case a_date
        when DateTime, Date, Time then a_date
        # FIXME distiguish between timestamp and YYYYMMDD string
        else DateTime.parse(a_date).strftime('%Y%m%d') 
      end
    end

    # setter for converting bidding_strategy to google format
    # can be either string (just xsi_type) or hash (xsi_type with params)
    # TODO validations for xsi_type
    # 
    # TODO watch out when doing update. according to documentation:
    # "to modify an existing campaign's bidding strategy, use 
    # CampaignOperation.biddingTransition" 
    #
    def bidding_strategy=(params = {})
      unless params.is_a?(Hash)
        params = { xsi_type: params }
      else
        if params[:bid_ceiling] and not params[:bid_ceiling].is_a?(Hash)
          params[:bid_ceiling] = {
            micro_amount: Api.to_micro_units(params[:bid_ceiling])
          }
        end
      end

      @bidding_strategy = params
    end

    # setter for converting budget to GoogleApi
    # budget can be integer (amount) or hash
    #
    def budget=(params = {})
      # if it's single value, it's a budget amount
      params = { amount: params } unless params.is_a?(Hash)

      if params[:amount] and not params[:amount].is_a?(Hash)
        params[:amount] = { micro_amount: Api.to_micro_units(params[:amount]) }
      end

      @budget = params.merge( period: 'DAILY', delivery_method: 'STANDARD' ) 
    end

    # create campaign with ad_groups and ads
    #
    def create
      return false unless self.valid?      
      
      # create basic campaign attributes
      operand = Hash[
        [ :name, :status, :start_date, :end_date,
          :budget, :bidding_strategy, :network_setting ].map do |k|
          [ k.to_sym, self.send(k) ] if self.send(k)
        end.compact
      ]

      response = self.mutate( 
        operator: 'ADD', 
        operand: operand
      )

      check_for_errors(self)

      self.id = response[:value].first[:id] rescue nil
      
      if criteria && criteria.size > 0
        new_criteria = Adapi::CampaignCriterion.create(
          campaign_id: @id,
          criteria: criteria
        )

        check_for_errors(new_criteria)
      end

      ad_groups.each do |ad_group_data|
        ad_group = Adapi::AdGroup.create(
          ad_group_data.merge( campaign_id: @id )
        )

        check_for_errors(ad_group, :prefix => "AdGroup \"#{ad_group[:id] || ad_group[:name]}\"")
      end

      self.errors.empty?

    rescue CampaignError => e
      false
    end

    # Sets campaign data en masse, including criteria and ad_groups with keywords and ads
    #
    # Warning: campaign data are not refreshed after update! We'd have to do it by get method
    # and that would slow us down. If you want to see latest data, you have to fetch them again
    # manually: Campaign#find or Campaign#find_complete
    #
    # TODO implement primarily as class method, instance will be just a redirect with campaign_id
    # 
    def update(params = {})
      # REFACTOR for the moment, we use separate campaign object just to prepare and execute 
      # campaign update request. This is kinda ugly and should be eventually refactored (if
      # only because of weird transfer of potential errors later when dealing with response). 
      #
      # campaign basic data workflow: 
      # parse given params by loading them into Campaign.new and reading them back, parsed
      # REFACTOR should be parsed by separate Campaign class method
      #
      campaign = Adapi::Campaign.new(params)
      # HOTFIX remove :service_name param inserted byu initialize method
      params.delete(:service_name)
      # ...and load parsed params back into the hash
      params.keys.each { |k| params[k] = campaign.send(k) }
      params[:id] = @id

      @criteria = params.delete(:criteria)
      params.delete(:targets)
      @ad_groups = params.delete(:ad_groups) || []

      @bidding_strategy = params.delete(:bidding_strategy)

      operation = { 
        operator: 'SET', 
        operand: params
      }

      # BiddingStrategy update has slightly different DSL from other params 
      # https://developers.google.com/adwords/api/docs/reference/v201109_1/CampaignService.BiddingTransition
      #
      # See this post about BiddingTransition limitations:
      # https://groups.google.com/forum/?fromgroups#!topic/adwords-api/tmRk1m7PbhU
      # "ManualCPC can transition to anything and everything else can only transition to ManualCPC" 
      if @bidding_strategy
        operation[:bidding_transition] = { target_bidding_strategy: @bidding_strategy }
      end
 
      campaign.mutate(operation)

      check_for_errors(campaign)

      # update campaign criteria
      if @criteria && @criteria.size > 0
        new_criteria = Adapi::CampaignCriterion.new(
          :campaign_id => @id,
          :criteria => @criteria
        )

        new_criteria.update!

        check_for_errors(new_criteria)        
      end

      self.update_ad_groups!(@ad_groups)

      self.errors.empty?

    rescue CampaignError => e
      false
    end

    # helper method that updates ad_groups. called from Campaign#update method
    #
    def update_ad_groups!(ad_groups = [])
      return true if ad_groups.nil? or ad_groups.empty?

      # FIXME deep symbolize_keys
      ad_groups.map! { |ag| ag.symbolize_keys } 

      # check if every ad_group has either :id or :name parameter
      ad_groups.each do |ag|
        if ag[:id].blank? && ag[:name].blank?
          self.errors.add("AdGroup", "required parameter (:id or :name) is missing")
          return false
        end
      end

      # get current ad_groups
      original_ad_groups = AdGroup.find(:all, :campaign_id => @id)

      ad_groups.each do |ad_group_data|
        ad_group_data[:campaign_id] = @id

        # find ad_group by id or name 
        k, v = ad_group_data.has_key?(:id) ? [:id, ad_group_data[:id]] : [:name, ad_group_data[:name]] 
        ad_group = original_ad_groups.find { |ag| ag[k] == v } 

        # update existing ad_group 
        if ad_group.present?
          ad_group.update(ad_group_data)

          original_ad_groups.delete_if { |ag| ag[k] == v }

        # create new ad_group
        # FIXME report error if searching by :id, because such ad_group should exists
        else
          ad_group_data.delete(:id)
          ad_group = AdGroup.create(ad_group_data)
        end

        check_for_errors(ad_group, :prefix => "AdGroup \"#{ad_group[:id] || ad_group[:name]}\"")
      end

      # delete ad_groups which haven't been updated
      original_ad_groups.each do |ag| 
        unless ag.delete
          # FIXME storing error twice for the moment because neither
          # of these errors says all the needed information
          self.errors.add("AdGroup #{ag[:id]}", "could not be deleted")
          self.store_errors(ad_group, "AdGroup #{ag[:id]}")
          return false
        end
      end

      self.errors.empty?

    rescue CampaignError => e
      false
    end

    def activate; update(:status => 'ACTIVE'); end

    def pause; update(:status => 'PAUSED'); end

    # Deletes campaign - which means simply setting its status to deleted
    #
    def delete; update(:status => 'DELETED'); end

    def rename(new_name); update(:name => new_name); end

    # Deletes campaign if not already deleted. This is usually done after 
    # unsuccessfull complex operation (create/update complete campaign)
    #
    def rollback
      if (@status == 'DELETED')
        self.errors.add(:base, 'Campaign is already deleted.')
        return false
      end

      update(
        :name => "#{@name}_DELETED_#{(Time.now.to_f * 1000).to_i}",
        :status => 'DELETED'
      )
    end

    # Shortcut method, often used for refreshing campaign after create/update
    # REFACTOR into :refresh method
    #
    def find
      Campaign.find(:first, :id => @id)
    end

    # Searches for campaign/s according to given parameters
    #
    # Input parameters are dynamic.
    # Special case: single number or string on input is considered to be id
    # and we want to search for a single campaign by id
    #
    def self.find(amount = :all, params = {})
      # find single campaign by id
      if params.empty? and not amount.is_a?(Symbol)
        params[:id] = amount.to_i
        amount = :first
      end

      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      predicates = [ :id ].map do |param_name|
        if params[param_name]
          # convert to array
          value = Array.try_convert(params[param_name]) ? params_param_name : [params[param_name]]
          { field: param_name.to_s.camelcase, operator: 'IN', values: value }
        end
      end.compact

      # TODO make configurable (but for the moment, return everything)
      select_fields = %w{ Id Name Status ServingStatus 
        StartDate EndDate AdServingOptimizationStatus } 
      # retrieve CampaignStats fields
      select_fields += %w{ Clicks Impressions Cost Ctr }
      # retrieve Budget fields
      select_fields += %w{ Amount Period DeliveryMethod } 
      # retrieve BiddingStrategy fields
      select_fields += %w{ BiddingStrategy BidCeiling EnhancedCpcEnabled }
      # retrieve NetworkSetting fields
      select_fields += NETWORK_SETTING_KEYS.map { |k| k.to_s.camelize } 

      selector = {
        :fields => select_fields,
        :ordering => [ { field: 'Name', sort_order: 'ASCENDING' } ],
        :predicates => predicates
      }

      response = Campaign.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      response.map! do |campaign_data|
        campaign = Campaign.new(campaign_data)
        # TODO allow mass assignment of :id
        campaign.id = campaign_data[:id]
        campaign
      end

      first_only ? response.first : response
    end

    def find_ad_groups(first_only = true)
      AdGroup.find( (first_only ? :first : :all), :campaign_id => self.id )
    end

    # Returns complete campaign data: criteria, ad groups, keywords and ads.
    # Basically everything what you can set when creating a campaign.
    #
    def self.find_complete(campaign_id)
      campaign = self.find(campaign_id)
      
      campaign[:criteria] = CampaignCriterion.find(:campaign_id => campaign.to_param)

      campaign[:ad_groups] = AdGroup.find(:all, :campaign_id => campaign.to_param)

      campaign
    end

  end
end
