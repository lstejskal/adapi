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
      
      operand = Hash[
        [ :name, :status, :start_date, :end_date,
          :budget, :bidding_strategy, :network_setting ].map do |k|
          [ k.to_sym, self.send(k) ] if self.send(k)
        end.compact
      ]

      response = self.mutate(
        :operator => 'ADD', 
        :operand => operand
      )
      
      return false unless (response and response[:value])
      
      self.id = response[:value].first[:id] rescue nil
      
      # create criteria (former targets) if they are available
      if criteria.size > 0
        criterion = Adapi::CampaignCriterion.create(
          :campaign_id => @id,
          :criteria => criteria
        )
        
        if (criterion.errors.size > 0)
          self.errors.add("[campaign criterion]", criterion.errors.to_a)
          self.rollback
          return false 
        end
      end

      ad_groups.each do |ad_group_data|
        ad_group = Adapi::AdGroup.create(
          ad_group_data.merge(:campaign_id => @id)
        )

        if (ad_group.errors.size > 0)
          self.errors.add("[ad group] \"#{ad_group.name}\"", ad_group.errors.to_a)
          self.rollback
          return false 
        end
      end

      true
    end

    # Sets campaign data en masse, including ad_groups, keywords and ads
    #
    # TODO implement primarily as class method, instance will be just a redirect with campaign_id
    # 
    def update(params = {})
      # HOTFIX can't use current instance, gotta create new one
      response = Adapi::Campaign.new().mutate(
        :operator => 'SET', 
        :operand => params.merge(:id => @id)
      )

      return false unless (response and response[:value])

      params.each_pair { |k,v| self.send("#{k}=", v) }

      true
    end

    def activate; update(:status => 'ACTIVE'); end
    def pause; update(:status => 'PAUSED'); end

    # Deletes campaign - which means, sets its status to deleted (because
    # AdWords campaigns are never really deleted.)
    #
    def delete; update(:status => 'DELETED'); end

    def rename(new_name); update(:name => new_name); end

    # when Campaign#create fails, "delete" campaign

    # Deletes campaign if it's not already deleted. For more information about
    # "deleted" campaigns, see `delete` method
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

    def find # == refresh
      Campaign.find(:first, :id => @id)
    end

    # if nothing else than single number or string at the input, assume it's an
    # id and we want to find campaign by id
    #
    def self.find(amount = :all, params = {})
      # find campaign by id - related syntactic sugar
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
          {:field => param_name.to_s.camelcase, :operator => 'IN', :values => value }
        end
      end.compact

      # TODO make configurable (but for the moment, return everything)
      select_fields = [ 'Id', 'Name', 'Status', 'ServingStatus', 'BiddingStrategy', 
        'Clicks', 'Impressions', 'Cost', 'Ctr', 'StartDate', 'EndDate',
        'AdServingOptimizationStatus' ]
      # retrieve Budget fields
      select_fields += [ 'Amount', 'Period', 'DeliveryMethod' ] 
      # retrieve NetworkSetting fields
      select_fields += NETWORK_SETTING_KEYS.map { |k| k.to_s.camelize } 

      # TODO display the rest of the data
      # TODO get NetworkSetting - setting as in fields doesn't work
      selector = {
        :fields => select_fields,
        :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
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

    # Converts campaign data to hash - of the same structure which is used when
    # creating a campaign.
    #
    # PS: could be implemented more succintly, but let's leave it like this for
    # now, code can change and this is more readable
    #
    def to_hash
      {
        :id => self[:id],
        :name => self[:name],
        :status => self[:status],
        :budget => self[:budget],
        :bidding_strategy => self[:bidding_strategy],
        :criteria => self[:criteria],
        :ad_groups => self[:ad_groups]
      }
    end

  end
end
