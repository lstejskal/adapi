module Adapi
  class Campaign < Api

    def initialize(params = {})
      params[:service_name] = :CampaignService
      super(params)
   end

    # TODO validation of input data
    def create # or update, if campaign has id
      # prepare for adding campaign
      ad_groups = params[:data].delete(:ad_groups).to_a
      
      operation = { :operator => 'ADD', :operand => params[:data] }
    
      response = @service.mutate([operation])

      campaign = nil
      if response and response[:value]
        campaign = response[:value].first
        puts "Campaign with name '%s' and ID %d was added." % [campaign[:name], campaign[:id]]
      else
        return nil
      end

      # if campaign has ad_groups, create them as well
      ad_groups.each do |ad_group_data|
        Adapi::AdGroup.new(
          :api_adwords_instance => self.adwords,
          :data => ad_group_data.merge(:campaign_id => campaign[:id])
        ).create
      end

      # if something goes wrong...

      # otherwise return campaign object, id or something what enables user to find campaign
    end

    # should be sorted out later, but leave it be for now
    #
    def find(params = {})

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

      response = @service.get(selector)

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
