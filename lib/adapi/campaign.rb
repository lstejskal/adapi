# encoding: utf-8

module Adapi
  class Campaign < Api

    # http://code.google.com/apis/adwords/docs/reference/latest/CampaignService.Campaign.html
    #
    attr_accessor :name, :serving_status, :start_date, :end_date, :budget,
      :bidding_strategy, :network_setting, :targets, :ad_groups

    def attributes
      super.merge('name' => name, 'start_date' => start_date, 'end_date' => end_date,
        'budget' => budget, 'bidding_strategy' => bidding_strategy,
        'network_setting' => network_setting, 'targets' => targets,
        'ad_groups' => ad_groups)
    end

    validates_presence_of :name, :status
    validates_inclusion_of :status, :in => %w{ ACTIVE DELETED PAUSED }

    def initialize(params = {})
      params[:service_name] = :CampaignService
      
      @xsi_type = 'Campaign'

      %w{ name status start_date end_date budget bidding_strategy
      network_setting targets ad_groups}.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      # convert bidding_strategy to GoogleApi
      # can be either string (just xsi_type) or hash (xsi_type with params)
      # TODO validations for xsi_type
      # 
      unless @bidding_strategy.is_a?(Hash)
        @bidding_strategy = { :xsi_type => @bidding_strategy }
      end

      if @bidding_strategy[:bid_ceiling] and not @bidding_strategy[:bid_ceiling].is_a?(Hash)
        @bidding_strategy[:bid_ceiling] = {
          :micro_amount => Api.to_micro_units(@bidding_strategy[:bid_ceiling])
        }
      end

      # convert budget to GoogleApi
      # TODO validations for budget
      #
      # budget can be integer (amount) or hash
      @budget = { :amount => @budget } unless @budget.is_a?(Hash)
      @budget[:period] ||= 'DAILY'
      if @budget[:amount] and not @budget[:amount].is_a?(Hash)
        @budget[:amount] = { :micro_amount => Api.to_micro_units(@budget[:amount]) }
      end
      # PS: not sure if this should be a default. maybe we don't even need it
      @budget[:delivery_method] ||= 'STANDARD'

      @targets ||= []
      @ad_groups ||= []

      super(params)
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
      
      # create targets if they are available
      if targets.size > 0
        target = Adapi::CampaignTarget.create(
          :campaign_id => @id,
          :targets => targets
        )
        
        if (target.errors.size > 0)
          self.errors.add("[campaign target]", target.errors.to_a)
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

      return true
    end

    # general method for changing campaign data
    # TODO enable updating of all campaign parts at once, same as for Campaign#create method
    #
    # TODO implement class method
    # 
    def update(params = {})
      # TODO validation or refuse to update

      response = self.mutate(
        :operator => 'SET', 
        :operand => params.merge(:id => @id)
      )

      return false unless (response and response[:value])

      # faster than self.find
      params.each_pair { |k,v| self.send("#{k}=", v) }

      true      
    end

    def activate; update(:status => 'ACTIVE'); end
    def pause; update(:status => 'PAUSED'); end
    def delete; update(:status => 'DELETED'); end

    def rename(new_name); update(:name => new_name); end

    # when Campaign#create fails, "delete" campaign
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
          {:field => param_name.to_s.camelcase, :operator => 'EQUALS', :values => params[param_name] }
        end
      end.compact

      # TODO display the rest of the data
      # TODO get NetworkSetting - setting as in fields doesn't work
      selector = {
        :fields => ['Id', 'Name', 'Status', 'BiddingStrategy'],
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

    # Returns complete campaign data: targets, ad groups, keywords and ads.
    # Basically everything what you can set when creating a campaign.
    #
    def self.find_complete(campaign_id)
      campaign = self.find(campaign_id)
      
      campaign[:targets] = CampaignTarget.find(:campaign_id => campaign.to_param)

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
        :targets => self[:targets],
        :ad_groups => self[:ad_groups]
      }
    end

  end
end
