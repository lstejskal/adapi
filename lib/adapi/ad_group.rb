module Adapi
  class AdGroup < Api

    def initialize(params = {})
      params[:service_name] = :AdGroupService
      super(params)
    end

    def create
      # prepare for adding campaign
      operation = { :operator => 'ADD', :operand => params[:data] }
    
      response = @service.mutate([operation])

      ad_group = response[:value].first

      return ad_group

      puts "Ad group ID %d was successfully added." % ad_group[:id]
    end

    # should be sorted out later, but leave it be for now
    #
    def find(params = {})
      raise "No Campaign ID" unless params[:campaign_id]
      campaign_id = params[:campaign_id]

      selector = {
        :fields => ['Id', 'Name'],
        # :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => [{
          :field => 'CampaignId', :operator => 'EQUALS', :values => campaign_id
        }]
      }

      response = @service.get(selector)

      if response and response[:entries]
        ad_groups = response[:entries]
        puts "Campaign ##{campaign_id} has #{ad_groups.length} ad group(s)."
        ad_groups.each do |ad_group|
          puts "  Ad group name is \"#{ad_group[:name]}\" and id is #{ad_group[:id]}."
        end
     else
       puts "No ad groups found for campaign ##{campaign_id}."
     end

    end

  end
end
