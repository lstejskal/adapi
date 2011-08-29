module Adapi
  class AdGroupCriterion < Api

    def initialize(params = {})
      params[:service_name] = :AdGroupCriterionService
      super(params)
    end

    def self.create(params = {})
      ad_group_criterion_service = AdGroupCriterion.new

      raise "No criteria available" unless params[:criteria].is_a?(Array)

      # if ad_group_id is supplied as separate parameter, include it into
      # criteria
      if params[:ad_group_id]
        params[:criteria].map! { |c| c.merge(:ad_group_id => params[:ad_group_id].to_i) }
      end

      operation = params[:criteria].map do |criterion|
        { :operator => 'ADD', :operand => criterion }
      end
    
      response = ad_group_criterion_service.service.mutate(operation)

      ad_group_criteria = nil
      if response and response[:value]
        ad_group_criteria = response[:value]
        puts "Added #{ad_group_criteria.length} criteria " # "to ad group #{ad_group_id}."
        ad_group_criteria.each do |ad_group_criterion|
          puts "  Criterion id is #{ad_group_criterion[:criterion][:id]} and " +
            "type is #{ad_group_criterion[:criterion][:"@xsi:type"]}."
        end
      else
        puts "No criteria were added."
      end

      ad_group_criteria 
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
