module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/CampaignTargetService.html
  #
  class CampaignTarget < Api

    attr_accessor :campaign_id, :targets

    validates_presence_of :campaign_id

    # TODO validate if target are in correct format

    # PS: create won't work with id and ad_group_id
    # 'id' => id, 'ad_group_id' => ad_group_id, 
    def attributes
      { 'targets' => targets }
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

      require 'pp'
      pp operations

      response = self.mutate(operations)

      targets = response[:value] || []
      targets.each do |target|
        puts "Campaign target of type #{target[:"@xsi:type"]} for campaign id " +
          "#{target[:campaign_id]} was set."
      end

      (response and response[:value]) ? true : false
    end
  
    alias :create :set
  
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
                radius_in_units, radius_units = parse_radius(geo_values[:radius])
                long, lat = parse_geodata(geo_values[:geo_point])

                {
                  :xsi_type => "#{geo_type.to_s.capitalize}Target",
                  :excluded => false,
                  :radius_in_units => radius_in_units,
                  :radius_distance_units => radius_units,
                  :geo_point => {
                    :longitude_in_micro_degrees => long,
                    :latitude_in_micro_degrees => lat
                  }                  
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

    def self.parse_radius(radius)
      radius_in_units, radius_units = radius.split(' ', 2)
      [
        radius_in_units.to_i,
        (radius_units == 'm') ? 'MILES' : 'KILOMETERS'
      ]
    end

    # parse longitude and lattitude from string in this format:
    # "longitude,lattitude" to [int,int] in Google microdegrees
    # for example: "38.89859,-77.035971" -> [38898590, -77035971]
    #
    def self.parse_geodata(long_lat)
      long_lat.split(',', 2).map { |x| to_microdegrees(x) }
    end

    # convert latitude or longitude data to microdegrees,
    # a format with AdWords API accepts
    #
    def self.to_microdegrees(x)
      (x.to_f * 1e6).to_i
    end

  end
end
