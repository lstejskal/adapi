# encoding: utf-8

module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/CampaignTargetService.html
  #
  class CampaignCriterion < Api

    attr_accessor :campaign_id, :criteria

    validates_presence_of :campaign_id

    # TODO validate that criteria are in correct format

    def attributes
      super.merge( 'campaign_id' => campaign_id, 'criteria' => criteria )
    end

    def initialize(params = {})
      params[:service_name] = :CampaignCriterionService

      @xsi_type = 'CampaignCriterion'

      %w{ campaign_id criteria }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def create
      # step 1 - convert input hash to new array of criteria
      # example: :language => [ :en, :cz ] ->  [:language, :en]
      criteria_array = []

      @criteria.each_pair do |criterion_type, criterion_settings|
        case criterion_type
        when :language
          criterion_settings.each do |value|
            criteria_array << [criterion_type, value]
          end
        # location subtypes
        # core: id, proximity
        # interpreted (TBI): city, province, country
        when :location
          criterion_settings.each_pair do |key, value|
            case key
              when :id
                value = [value] unless value.is_a?(Array)
                value.each { |v| criteria_array << [criterion_type, v] }
              else
                warn "Unknown location criterion type: %s" % key
                nil
            end
          end
        else
          warn "Unknown criterion type: %s" % criterion_type
          nil
        end
      end

      # step 2 - convert individual criteria to low-level google params
      operations = criteria_array.map do |criterion_type, criterion_settings|
        {
          :operator => 'ADD',
          :operand => {
            :campaign_id => @campaign_id,
            :criterion => CampaignCriterion::create_criterion(criterion_type, criterion_settings)
          }
        }
      end
      
      p criteria_array
      p '!!!'

      response = self.mutate(operations)

      (response and response[:value]) ? true : false
    end
  
    def self.find(params = {})
      params.symbolize_keys!

      # by default, skip criteria types that have no criterion data
      params[:skip_empty_criterion_types] ||= true
      
      if params[:conditions]
        params[:campaign_id] = params[:campaign_id] || params[:conditions][:campaign_id]
      end

      raise ArgumentError, "Campaing ID is required" unless params[:campaign_id]

      predicates = [ :campaign_id ].map do |param_name|
        if params[param_name]
          # convert to array
          value = Array.try_convert(params[param_name]) ? params_param_name : [params[param_name]]
          {:field => param_name.to_s.camelcase, :operator => 'IN', :values => value }
        end
      end.compact

      # TODO: get more fields
      selector = {
        :fields => ['Id'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }
  
      response = CampaignCriterion.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      # return everything or only 
      if params[:skip_empty_criterion_types]
        response.select! { |criterion_type| criterion_type.has_key?(:criteria) }
      end

      # TODO optionally return just certain type(s)
      # easy, just add condition (single type or array), filter and set
      # :skip_empty_target_types option to false

      response
    end

    # Transforms our custom high-level criteria parameters to AdWords API parameters
    # 
    # TODO allow to enter AdWords API parameters in original format
    #
    def self.create_criterion(criterion_type, criterion_data)
      case criterion_type
        # example: [:language, 'en'] -> {:xsi_type => 'Language', :id => 1000}
        when :language
          { :xsi_type => 'Language', :id => language_id(criterion_data) }

        when :location
          unless criterion_data.is_a?(Hash)
            criterion_data = { :type => :id, :value => criterion_data } 
          end
          
          case location_type = criterion_data.delete(:type)
            when :id
              { :xsi_type => 'Location', :id => criterion_data[:value].to_i }
            when :proximity
              radius_in_units, radius_units = parse_radius(criterion_data[:radius])
              long, lat = parse_geodata(criterion_data[:geo_point])

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
=begin
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
=end
        end

        else nil 
      end
    end

    # Return AdWords API language id based for language code
    #
    # REFACTOR
    LANGUAGE_IDS = { :en => 1000, :de => 1001, :fr => 1002, :es => 1003,
      :it => 1004, :ja => 1005, :da => 1009, :nl => 1010, :fi => 1011, :ko => 1012,
      :no => 1013, :pt => 1014, :sv => 1015, :zh_CN => 1017, :zh_TW => 1018,
      :ar => 1019, :bg => 1020, :cs => 1021, :el => 1022, :hi => 1023, :hu => 1024,
      :id => 1025, :is => 1026, :iw => 1027, :lv => 1028, :lt => 1029, :pl => 1030,
      :ru => 1031, :ro => 1032, :sk => 1033, :sl => 1034, :sr => 1035, :uk => 1036,
      :tr => 1037, :ca => 1038, :hr => 1039, :vi => 1040, :ur => 1041, :tl => 1042,
      :et => 1043, :th => 1044
    }
    def self.language_id(language_alias)
      LANGUAGE_IDS[language_alias.to_sym.downcase]
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
