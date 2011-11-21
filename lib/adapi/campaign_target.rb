# encoding: utf-8

module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/CampaignTargetService.html
  #
  class CampaignTarget < Api

    attr_accessor :campaign_id, :targets

    validates_presence_of :campaign_id

    # TODO validate if targets are in correct format

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

      # by default, return skip target types that have no target data
      params[:skip_empty_target_types] ||= true
      
      if params[:conditions]
        params[:campaign_id] = params[:campaign_id] || params[:conditions][:campaign_id]
      end

      raise ArgumentError, "Campaing ID is required" unless params[:campaign_id]
  
      selector = { :campaign_ids => [ params[:campaign_id].to_i ] }
  
      response = CampaignTarget.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      # return everything or only 
      if params[:skip_empty_target_types]
        response.select! { |target_type| target_type.has_key?(:targets) }
      end

      # TODO optionally return just certain target type(s)
      # easy, just add condition (single type or array), filter and set
      # :skip_empty_target_types option to false
      
      # TODO optionally convert to original input shortcuts

      response
    end

    # transform our own high-level target parameters to google low-level
    #
    def self.create_targets(target_type, target_data)
      case target_type
        when :language
          target_data.map { |language| { :language_code => language.to_s.downcase } }       
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

              when :city
                geo_values.merge(
                  :xsi_type => "#{geo_type.to_s.capitalize}Target",
                  :excluded => false
                )

              else # :country, :province
                {
                  :xsi_type => "#{geo_type.to_s.capitalize}Target",
                  :excluded => false,
                  "#{geo_type}_code".to_sym => to_uppercase(geo_values)
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
    # TODO alias :to_microdegrees :to_micro_units
    #
    def self.to_microdegrees(x)
      Api.to_micro_units(x)
    end

    # convert either single value or array of value to uppercase
    # 
    def self.to_uppercase(values)
      if values.is_a?(Array)
        values.map { |value| value.to_s.upcase }
      else
        values.to_s.upcase
      end
    end

  end
end
