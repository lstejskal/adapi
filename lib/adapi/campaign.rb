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

      @targets ||= []
      @ad_groups ||= []

      super(params)
    end

    # create campaign with ad_groups and ads
    #
    def create
      response = self.mutate(
        :operator => 'ADD', 
        :operand => {
          :name => @name,
          :status => @status,
          # start_date
          # end_date
          :budget => @budget,
          :bidding_strategy => @bidding_strategy,
          :network_setting => @network_setting,
        }
      )

      return false unless (response and response[:value])
      
      self.id = response[:value].first[:id] rescue nil
      
      # create targets if they are available
      if targets
        target = Adapi::CampaignTarget.create(
          :campaign_id => @id,
          :targets => targets
        )
        p target.errors.full_messages if (target.errors.size > 0)
      end

      ad_groups.each do |ad_group_data|
        ad_group = Adapi::AdGroup.create(
          ad_group_data.merge(:campaign_id => @id)
        )
        p ad_group.errors.full_messages if (ad_group.errors.size > 0)
      end

      return true
    end

    # general method for changing campaign data
    # TODO enable updating of all campaign parts at once, same as for Campaign#create method
    # 
    def self.update(params = {})
      campaign_service = Campaign.new

      # give users options to shorten input params
      params = { :data => params } unless params.has_key?(:data)

      campaign_id = params[:id] || params[:data][:id] || nil
      return nil unless campaign_id
      
      operation = { :operator => 'SET',
        :operand => params[:data].merge(:id => campaign_id.to_i)
      }
    
      response = campaign_service.service.mutate([operation])

      if response and response[:value]
        campaign = response[:value].first
        puts 'Campaign id %d successfully updated.' % campaign[:id]
      else
        puts 'No campaigns were updated.'
      end

      return campaign
    end

    def self.set_status(params = {})
      params[:id] ||= (params[:data] || params[:data][:id]) || nil
      return nil unless params[:id]
      return nil unless %w{ ACTIVE PAUSED DELETED }.include?(params[:status])

      self.update(:id => params[:id], :status => params[:status])
    end

    def self.activate(params = {})
      self.set_status params.merge(:status => 'ACTIVE')
    end

    def self.pause(params = {})
      self.set_status params.merge(:status => 'PAUSED')
    end

    def self.delete(params = {})
      self.set_status params.merge(:status => 'DELETED')
    end

    def self.rename(params = {})
      params[:id] ||= (params[:data] || params[:data][:id]) || nil
      return nil unless (params[:id] && params[:name])

      self.update(:id => params[:id], :name => params[:name])
    end

    def self.find(params = {})
      campaign_service = Campaign.new

      selector = {
        :fields => ['Id', 'Name', 'Status']
        # :predicates => [{ :field => 'Id', :operator => 'EQUALS', :values => '334315' }]
        # :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}]
      }

      # set filtering conditions: find by id, status etc.
      if params[:conditions]
        selector[:predicates] = params[:conditions].map do |c|
          { :field => c[0].to_s.capitalize, :operator => 'EQUALS', :values => c[1] }
        end
      end

      response = campaign_service.service.get(selector)

      return (response and response[:entries]) ? response[:entries].to_a : []
    
      if response
        response[:entries].to_a.each do |campaign|
          puts "Campaign name is \"#{campaign[:name]}\", id is #{campaign[:id]} " +
              "and status is \"#{campaign[:status]}\"."
        end
      else
        puts "No campaigns were found."
      end
    end

  end
end
