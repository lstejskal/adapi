module Adapi
  class Campaign < Api

    # PS: if we're going to implement instance mehtods, let's put all
    # campaing-related data in :data hash. Don't create attributes yet

    def initialize(params = {})
      params[:service_name] = :CampaignService
      super(params)
   end

    # campaign data can be passed either as single hash:
    # Campaign.create(:name => 'Campaign 123', :status => 'ENABLED')
    # or as hash in a :data key:
    # Campaign.create(:data => { :name => 'Campaign 123', :status => 'ENABLED' })
    #
    def self.create(params = {})
      campaign_service = Campaign.new

      # give users options to shorten input params
      params = { :data => params } unless params.has_key?(:data)

      # prepare for adding campaign
      ad_groups = params[:data].delete(:ad_groups).to_a
      targets = params[:data].delete(:targets)
      
      operation = { :operator => 'ADD', :operand => params[:data] }
    
      response = campaign_service.service.mutate([operation])

      campaign = nil
      if response and response[:value]
        campaign = response[:value].first
        puts "Campaign with name '%s' and ID %d was added." % [campaign[:name], campaign[:id]]
      else
        return nil
      end

      # create targets if they are available
      if targets
        Adapi::CampaignTarget.create(
          :campaign_id => campaign[:id],
          :targets => targets,
          :api_adwords_instance => campaign_service.adwords
        )
      end

      # if campaign has ad_groups, create them as well
      ad_groups.each do |ad_group_data|
        Adapi::AdGroup.create(
          :data => ad_group_data.merge(:campaign_id => campaign[:id]),
          :api_adwords_instance => campaign_service.adwords
        )
      end

      campaign

      # if something goes wrong...

      # otherwise return campaign object, id or something what enables user to find campaign
    end

    # general method for changing campaign data
    # TODO enable updating of all campaign parts at once,  same as for Campaign#create method
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


    # should be sorted out later, but leave it be for now
    #
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
