module Adapi
  class AdGroup < Api
  
    attr_accessor :campaign_id, :name, :bids, :keywords, :ads

    validates_presence_of :campaign_id, :name

    def attributes
      super.merge('campaign_id' => campaign_id, 'name' => name, 'bids' => bids)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupService

      @xsi_type = 'AdGroup'

      %w{ campaign_id name bids keywords ads }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      @keywords ||= []
      @ads ||= []

      super(params)
    end

    def create
      p self.attributes
      
      response = self.mutate(
        :operator => 'ADD', 
        :operand => {
          :campaign_id => @campaign_id,
          :name => @name,
          :bids => @bids
        }
      )

      ad_group = response[:value].first

      return false unless (response and response[:value])
      
      self.id = response[:value].first[:id] rescue nil
      
      if @keywords.size > 0
        Adapi::AdGroupCriterion.create(
          :ad_group_id => @id,
          :criteria => @keywords
        )
      end

      @ads.each do |ad_data|
        ad = Adapi::Ad.create( ad_data.merge(:ad_group_id => @id) )
        p ad.errors.full_messages if (ad.errors.size > 0)
      end

      true
    end

    # should be sorted out later, but leave it be for now
    #
    def self.find(params = {})
      ad_group_service = AdGroup.new

      raise "No Campaign ID" unless params[:campaign_id]
      campaign_id = params[:campaign_id]

      selector = {
        :fields => ['Id', 'Name'],
        # :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => [{
          :field => 'CampaignId', :operator => 'EQUALS', :values => campaign_id
        }]
      }

      response = ad_group_service.service.get(selector)

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
