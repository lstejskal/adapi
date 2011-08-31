module Adapi
  class Campaign < Api

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
