# encoding: utf-8

# This class is obsolete in v201109, CampaignCriterion is used instead. Only
# AdScheduleTarget is still being used, but it's not implemented yet.

module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/CampaignTargetService.html
  #
  class CampaignTarget < Api

    attr_accessor :campaign_id, :targets

    validates_presence_of :campaign_id

    def attributes
      super.merge( 'campaign_id' => campaign_id, 'targets' => targets )
    end

    def initialize(params = {})
      params[:service_name] = :CampaignTargetService

      @xsi_type = 'CampaignTarget'

      %w{ campaign_id targets }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def set
      # transform our own high-level target parameters to google low-level
      # target parameters
      operations = []

      @targets.each_pair do |targetting_type, targetting_settings|
        operations << { :operator => 'SET',
          :operand => {
            :xsi_type => "#{targetting_type.to_s.capitalize}TargetList",
            :campaign_id => @campaign_id,
            :targets => CampaignTarget::create_targets(targetting_type, targetting_settings)
          }
        }
      end

      response = self.mutate(operations)

      (response and response[:value]) ? true : false
    end
  
    alias :create :set

    def self.find(params = {})
      params.symbolize_keys!
      
      if params[:conditions]
        params[:campaign_id] = params[:campaign_id] || params[:conditions][:campaign_id]
      end

      raise ArgumentError, "Campaing ID is required" unless params[:campaign_id]
  
      selector = { :campaign_ids => [ params[:campaign_id].to_i ] }
  
      response = CampaignTarget.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      response
    end

    # Obsolete. Transforms our own high-level target parameters to google low-level
    #
    def self.create_targets(target_type, target_data)
      nil 
    end

  end
end
