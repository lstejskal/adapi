module Adapi
  # Ad::TextAd == AdGroupAd::TextAd
  #
  # http://code.google.com/apis/adwords/docs/reference/latest/AdGroupAdService.TextAd.html
  #
  class Ad::TextAd < Ad

    attr_accessor :headline, :description1, :description2

    # define_attribute_methods [ :headline, :description1, :description2 ]

    def attributes
      super.merge('headline' => headline, 'description1' => description1, 'description2' => description2)
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupAdService

      @xsi_type = 'TextAd'

      %w{ headline description1 description2 }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end
    
    def create
      operation = { :operator => 'ADD', 
        :operand => { :ad_group_id => @ad_group_id, :ad => self.data }
      } 
    
      response = @service.mutate([operation])

      (response and response[:value]) ? response[:value].first : nil
    end

    def self.create(params = {})
      TextAd.new(params).create
    end

    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      # for ActiveRecord compatibility, we don't use anything besides conditions
      # params for now
      params = params[:conditions] if params[:conditions]

      ad_service = Ad.new

      # we need ad_group_id
      rause ArgumentError, "AdGroup ID is required" unless params[:ad_group_id]
 
      # supported condition parameters: ad_group_id and id
      predicates = [ :ad_group_id, :id ].map do |param_name|
        if params[param_name]
          {:field => param_name.to_s.camelcase, :operator => 'EQUALS', :values => params[param_name] }
        end
      end.compact

      selector = {
        :fields => ['Id', 'Headline'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }

      response = ad_service.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      response.map! do |data|
        TextAd.new(data[:ad].merge(:ad_group_id => params[:ad_group_id]))
      end

      # TODO convert to TextAd instances
      # PS: we already have ad_group_id parameter
      first_only ? response.first : response
    end

  end
end
