# encoding: utf-8

module Adapi

  # http://code.google.com/apis/adwords/docs/reference/latest/CampaignTargetService.html
  #
  class CampaignCriterion < Api

    ATTRIBUTES = [ :campaign_id, :criteria ]

    attr_accessor *ATTRIBUTES 

    validates_presence_of :campaign_id

    CRITERION_TYPES = [ :age_range, :carrier, :content_label, :gender, :keyword,
      :language, :location, :operating_system_version, :placement, :platform,
      :polygon, :product, :proximity, :criterion_user_interest,
      :criterion_user_list, :vertical ]

    def attributes
      super.merge Hash[ ATTRIBUTES.map { |k| [k, self.send(k)] } ]
    end

    def initialize(params = {})
      params[:service_name] = :CampaignCriterionService
      params[:negative] ||= false

      @xsi_type = if (params[:negative] == true)
        'NegativeCampaignCriterion'
      else
        'CampaignCriterion'
      end

      ATTRIBUTES.each do |param_name|
        self.send "#{param_name}=", params[param_name]
      end

      # HOTFIX backward compatibility with old field for criteria
      @criteria ||= params[:targets] || {}

      super(params)
    end

    def create(operator = 'ADD')
      # step 1 - convert input hash to new array of criteria
      # example: :language => [ :en, :cs ] -> [ [:language, :en], [:language, :cs] ]
      criteria_array = []

      @criteria.each_pair do |criterion_type, criterion_settings|
        case criterion_type
          when :language
            Array(criterion_settings).each do |value|
              criteria_array << [criterion_type, value]
            end

          # location - besides standard, expected interface, this criterion is
          # heavily customized to comply with legacy interfaces (pre-v201109).
          #
          # Standard v201109 location interface:
          # :location => location_id
          # :location => { :id => location_id }
          # :location => { :id => [ location_id ] }
          #
          # Accepted subtypes:
          # id
          # proximity (just actually redirects to proximity criterion)
          # city
          # province
          # country
          #
          when :location, :geo # PS: geo is legacy synonym for location
            # handles ":location => location_id" shortcut
            unless criterion_settings.is_a?(Hash)
              criterion_settings = { :id => criterion_settings.to_i }
            end
            
            criterion_settings.each_pair do |subtype, subtype_settings|
              # any location subtypes can be in array
              subtype_settings = [ subtype_settings ] unless subtype_settings.is_a?(Array)
              
              case subtype
                when :id
                  subtype_settings.each do |value|
                    criteria_array << [:location, value]
                  end                  

                # find id for location(s) by LocationCriterion service
                when :name
                  subtype_settings = [subtype_settings] unless subtype_settings.is_a?(Array)
                  
                  subtype_settings.each do |location_criteria|                   
                    location = Adapi::Location.find(location_criteria)
  
                    raise "Location not found" if location.nil?

                    criteria_array << [ :location, location[:id] ]
                  end

                when :proximity
                  subtype_settings.each do |value|
                    criteria_array << [subtype, value]
                  end
                  
                else
                  raise "Unknown location subtype: %s" % subtype
              end
            end

          # not-supported criterions (they work, but have to be entered in
          # google format, no shortcuts are set up for them)
          else
            unless CRITERION_TYPES.include?(criterion_type)
              raise "Unknown criterion type; #{criterion_type}"
            end
          
            if criterion_settings.is_a?(Array)
              criterion_settings.each do |value|
                criteria_array << [criterion_type, value]
              end
            else
              criteria_array << [criterion_type, criterion_settings]
            end
          end
      end

      # step 2 - convert individual criteria to low-level google params
      operations = criteria_array.map do |criterion_type, criterion_settings|
        {
          :operator => operator,
          :operand => {
            :campaign_id => @campaign_id,
            :criterion => CampaignCriterion::create_criterion(criterion_type, criterion_settings)
          }
        }
      end
      
      response = self.mutate(operations)

      (response and response[:value]) ? true : false
    end

    # custom update method, which delete all current criteria and adds new ones
    #
    def update!
      result = self.delete_all!

      # TODO return error if result == false

      self.create
    end

    # REFACTOR
    def destroy
      self.create('REMOVE')
    end
  
    # Deletes all current campaign criteria
    #
    def delete_all!
      # find all current criteria and extract operand params from them 
      original_criteria = CampaignCriterion.find(:campaign_id => @campaign_id).map do |criterion|
        criterion.select { |k,v| [ :xsi_type, :id ].include?(k) }
      end

      # HOTFIX temporarily remove platforms, adwords api throws error on no platforms
      original_criteria.delete_if { |c| c[:xsi_type] == "Platform" }

      operations = original_criteria.map do |criterion|
        {
          :operator => 'REMOVE',
          :operand => {
            :campaign_id => @campaign_id,
            :criterion => criterion
          }
        }
      end
      
      response = self.mutate(operations)

      (response and response[:value]) ? true : false
    end

    def self.find(params = {})
      params.symbolize_keys!
      
      if params[:conditions]
        params[:campaign_id] = params[:campaign_id] || params[:conditions][:campaign_id]
      end

      raise ArgumentError, "Campaign ID is required" unless params[:campaign_id]

      predicates = [ :campaign_id ].map do |param_name|
        if params[param_name]
          # convert to array
          value = Array.try_convert(params[param_name]) ? params_param_name : [params[param_name]]
          {:field => param_name.to_s.camelcase, :operator => 'IN', :values => value }
        end
      end.compact

      # TODO list all applicable fields in select fields
      selector = {
        :fields => ['Id', 'CriteriaType', 'KeywordText', 'LocationName'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }
  
      response = CampaignCriterion.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      # TODO optionally return just certain type(s)
      # easy, just add condition (single type or array), filter and set
      # :skip_empty_target_types option to false

      # TODO add custom column :value, which will return criterion value
      # unrelated to the actual column where value is stored (code,
      # location_name, etc.)

      response.map { |entry| entry[:criterion] }.compact
    end

    # Transforms our custom high-level criteria parameters to AdWords API parameters
    #
    # Every criterion can be entered as high-level alias or as id
    #
    # Language:
    # :language => [ :en, :cs ]
    # :language => [ 1000, 1021 ] # integers!
    #
    # TODO return error if language cannot be found
    #
    def self.create_criterion(criterion_type, criterion_data)
      case criterion_type
        # 
        # example: [:language, 'en'] -> {:xsi_type => 'Language', :id => 1000}
        when :language
          {
            :xsi_type => 'Language',
            :id => ConstantData::Language.find(criterion_data).id
          }

        when :location
          {
            :xsi_type => 'Location',
            :id => criterion_data.to_i
          }

        when :proximity
          radius_in_units, radius_units = parse_radius(criterion_data[:radius])
          long, lat = parse_geodata(criterion_data[:geo_point])

          {
            :xsi_type => 'Proximity',
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
