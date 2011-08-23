module Adapi
  class Campaign < Api

    def initialize(params = {})
      params[:service_name] = :CampaignService
      super(params)
    end

    # should be sorted out later, but leave it be for now
    #
    def find(params = {})
      # Get all the campaigns for this account; empty selector.
      selector = {
        :fields => ['Id', 'Name', 'Status']
        # :predicates => [{ :field => 'Id', :operator => 'EQUALS', :values => '334315' }]
        # :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}]
      }

      response = @service.get(selector)
    
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
