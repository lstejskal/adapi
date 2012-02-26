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

          # location criterion - has custom sub-criteria:
          # core: id, proximity
          # interpreted (TBI): city, province, country
          when :location
            criterion_settings.each_pair do |subtype, values|
              case subtype
                # enter location as id
                when :id
                  values = [values] unless values.is_a?(Array)
                  values.each do |value|
                    criteria_array << [criterion_type, value]
                  end
                else
                  warn "Unknown location subtype: %s" % subtype
                  nil
              end
            end

          # not-supported criterions
          else
            criterion_settings.each do |value|
              criteria_array << [criterion_type, value]
            end
        end
      end

#       p '!!!'
#       p criteria_array

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
      
#      p '!!!'
#      p operations
      
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
    # Every criterion can be entered as high-level alias or as id
    #
    # Language:
    # :language => [ :en, :cs ]
    # :language => [ 1000, 1021 ] # integers!
    #
    #
    def self.create_criterion(criterion_type, criterion_data)
      case criterion_type
        # 
        # example: [:language, 'en'] -> {:xsi_type => 'Language', :id => 1000}
        when :language
          { :xsi_type => 'Language',
            :id => ConstantData::Language.find(criterion_data).id
          }

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
            end

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
        
        # unsupported criterion types
        else
          { :xsi_type => criterion_type.to_s.camelize }.merge(criterion_data)

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
