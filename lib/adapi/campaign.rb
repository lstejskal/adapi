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

      if @bidding_strategy[:bid_ceiling]
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
      @budget[:amount] = { :micro_amount => Api.to_micro_units(@budget[:amount]) }
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
          return false 
        end
      end

      ad_groups.each do |ad_group_data|
        ad_group = Adapi::AdGroup.create(
          ad_group_data.merge(:campaign_id => @id)
        )

        if (ad_group.errors.size > 0)
          self.errors.add("[ad group] \"#{ad_group.name}\"", ad_group.errors.to_a)
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

    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      raise "Campaign ID (:id param) is required" unless params[:id]

      predicates = [ :id ].map do |param_name|
        if params[param_name]
          {:field => param_name.to_s.camelcase, :operator => 'EQUALS', :values => params[param_name] }
        end
      end.compact

      selector = {
        :fields => ['Id', 'Name', 'Status', 'BiddingStrategy' ],
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

  end
end
