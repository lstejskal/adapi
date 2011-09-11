module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/CampaignTargetService.html
  #
  class CampaignTarget < Api

    def initialize(params = {})
      params[:service_name] = :CampaignTargetService
      super(params)
    end

    # FIXME params should be the same as in other services, for example ad_group 
    # 
    def self.create(params = {})
      campaign_target_service = CampaignTarget.new

      raise "No Campaign ID" unless params[:campaign_id]
      campaign_id = params[:campaign_id].to_i

      # transform our own high-level target parameters to google low-level
      # target parameters
      operations = []

      params[:targets].each_pair do |targetting_type, targetting_settings|
        operations << { :operator => 'SET',
          :operand => {
            :xsi_type => "#{targetting_type.to_s.capitalize}TargetList",
            :campaign_id => campaign_id,
            :targets => self.create_targets(targetting_type, targetting_settings)
          }
        }
      end

      response = campaign_target_service.service.mutate(operations)

      targets = response[:value] || []
      targets.each do |target|
        puts "Campaign target of type #{target[:"@xsi:type"]} for campaign id " +
          "#{target[:campaign_id]} was set."
      end

      targets
    end
  
    def self.find(params = {})
      campaign_target_service = CampaignTarget.new

      selector = {} # select all campaign targets by default
      selector[:campaign_ids] = params[:campaign_ids] if params[:campaign_ids]
  
      response = campaign_target_service.service.get(selector)

      targets = nil
      if response and response[:entries]
        targets = response[:entries]
        targets.each do |target|
          p target
        end
      else
        puts "No campaign targets found."
      end

      targets
    end

    # transform our own high-level target parameters to google low-level
    #
    def self.create_targets(target_type, target_data)
      case target_type
        when :language
          target_data.map { |language| { :language_code => language } }       
          # example: ['cz','sk'] => [{:language_code => 'cz'}, {:language_code => 'sk'}]
        when :geo
          target_data.map do |geo_type, geo_values|
            case geo_type
              when :proximity
                {
                  :xsi_type => "#{geo_type.to_s.capitalize}Target",
                  :excluded => false
                  
                }
              # TODO add support for more geo_values
              else # default, used for :country and :province
                {
                  :xsi_type => "#{geo_type.to_s.capitalize}Target",
                  :excluded => false,
                  "#{geo_type}_code".to_sym => geo_values
                }
            end
          end
        else nil 
      end
    end

    # parse longitude and lattitude from string in this format:
    # "longitude,lattitude" to [int,int] in Google microdegrees
    # for example: "38.89859,-77.035971" -> [38898590, -77035971]
    #
    def parse_geodata(long_lat)
      long_lat.split(',', 2).map { |x| to_microdegrees(x) }
    end

    # convert latitude or longitude data to microdegrees,
    # a format with AdWords API accepts
    #
    def to_microdegrees(x)
      (x.to_f * 1e6).to_i
    end

  end
end
