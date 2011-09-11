module Adapi
  class Keyword < AdGroupCriterion

    attr_accessor :keywords, :match_type

    def attributes
      super.merge('keywords' => keywords)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupCriterionService

      @xsi_type = 'AdGroupCriterion'

      %w{ keywords }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def create
      operations = @keywords.map do |keyword|
        {
          :operator => 'ADD', 
          :operand => {
            :xsi_type => (keyword[:negative] ? 'NegativeAdGroupCriterion' : 'BiddableAdGroupCriterion'),
            :ad_group_id => @ad_group_id,
            :criterion => {
              :xsi_type => 'Keyword',
              :text => keyword[:text],
              :match_type => keyword[:match_type]
            }
          }
        }
      end

      response = self.mutate(operations)

      return false unless (response and response[:value])
      
      self.keywords = response[:value].map { |keyword| keyword[:criterion] }

      true
    end

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
