# encoding: utf-8

# TODO map results of find to location object

module Adapi
  class Location < Api

    # display types. region was formerly called province, and province is still
    # supported as parameter, a synonym for region
    LOCATIONS_HIERARCHY = [ :city, :region, :country ]

    def initialize(params = {})
      params[:service_name] = :LocationCriterionService
      
      @xsi_type = 'LocationCriterion'

      super(params)
    end

    # Example:
    # Location.find(:city => 'Prague')
    # Location.find(:country => 'CZ', :city => 'Prague')
    # Location.find(:country => 'CZ', :region => 'Prague' :city => 'Prague')
    #
    # TODO add legacy aliases: :city_name, :province_code, :country_code
    #
    def self.find(amount = :all, params = {})
      # set amount = :first by default
      if amount.is_a?(Hash) and params.empty?
        params = amount.clone
        amount = :first
      end

      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      # in which language to retrieve locations
      params[:locale] ||= 'en'

      # support for legacy parameter
      if params[:province] and not params[:region]
        params[:region] = params[:province]
      end

      # if :country parameter is valid country code, replace it with country name
      if params[:country] && (params[:country].size == 2)
        country_name = ConstantData::Location::Country.find_name_by_country_code(params[:country])
        params[:country] = country_name if country_name
      end

      # determine by what criteria to search
      location_type, location_name = nil, nil
      LOCATIONS_HIERARCHY.each do |param_name|
        if params[param_name]
          # FIXME use correct helper instead of humanize HOTFIX
          location_type, location_name = param_name.to_s.humanize, params[param_name]
          break
        end
      end
      
      raise "Invalid params" unless location_name
      
      selector = {
        :fields => ['Id', 'LocationName', 'CanonicalName', 'DisplayType', 'ParentLocations', 'Reach'],
        :predicates => [
            # PS: for searching more locations at once, switch to IN operator
            # values array for EQUALS can contain only one value (sic!)
            { :field => 'LocationName', :operator => 'EQUALS', :values => [ location_name ] },
            { :field => 'Locale', :operator => 'EQUALS', :values => [ params[:locale] ] }
        ]
      }

      # returns array of locations. and now the fun begins    
      locations = Location.new.service.get(selector)
      
      # now we have to find location with correct display_type and TODO hierarchy
      # problematic example: Prague is both city and province (region)
      
      locations.each do |entry|
        next unless entry.is_a?(Hash)

        if entry[:location][:display_type] == location_type
          return entry[:location]
        end
      end
      
      nil
    end

    # Displays location tree - location with its parents
    # 
    def self.location_tree(location = {})
      "TODO"
    end

  end
end
