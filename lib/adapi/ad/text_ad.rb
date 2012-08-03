# encoding: utf-8

module Adapi
  # http://code.google.com/apis/adwords/docs/reference/latest/AdGroupAdService.TextAd.html
  #
  # Ad::TextAd == AdGroupAd::TextAd
  #
  # This model supports both individual and batch create/update of ads.
  # If :ads parameter is not nil, it is considered as array of ads to
  # be updated in batch.
  #
  class Ad::TextAd < Ad

    ATTRIBUTES = [ :headline, :description1, :description2, :ads ]

    attr_accessor *ATTRIBUTES

    def attributes
      super.merge Hash[ ATTRIBUTES.map { |k| [k, self.send(k)] } ]
    end

    alias to_hash attributes

    def initialize(params = {})
      params[:service_name] = :AdGroupAdService

      @xsi_type = 'TextAd'

      ATTRIBUTES.each do |param_name|
        self.send("#{param_name}=", params[param_name])
      end

      super(params)
    end

    def save
      self.new? ? self.create : self.update
    end
 
    def create
      @ads = [ self.attributes ] unless @ads 

      operations = []

      @ads.each do |ad_params|

        ad = TextAd.new(ad_params)

        operand = ad.attributes.delete_if do |k|
          [ :campaign_id, :ad_group_id, :id, :status, :ads ].include?(k.to_sym)
        end.symbolize_keys

        operations << {
          :operator => 'ADD',
          :operand => {
            :ad_group_id => ad.ad_group_id,
            :status => ad.status,
            :ad => operand
          }
        }
      end

      response = self.mutate(operations)

=begin
      # check for PolicyViolationErrors, set exemptions and try again
      # TODO for now, this is only done once. how about setting a number of retries?
      unless self.errors[:PolicyViolationError].empty?
        operation[:exemption_requests] = self.errors[:PolicyViolationError].map do |error_key|
          { :key => error_key }
        end

        self.errors.clear

        response = self.mutate(operation)
      end
=end

      return false unless self.errors.empty?

      # FIXME set ad id
      # self.id = response[:value].first[:ad][:id] rescue nil
  
      true
    end

    # except for status, we cannot edit ad fields
    # gotta delete an ad and create a new one instead
    # this means that this method returns new ad id! 
    # 
    # REFACTOR this method shpould be removed (but that might break something,
    # os let's keep it here for the moment)
    #
    def update(params = {})
      # set attributes for the "updated" ad
      create_attributes = self.attributes.merge(params).symbolize_keys
      create_attributes.delete(:id)

      # delete current ad
      return false unless self.destroy

      # create new add
      TextAd.create(create_attributes)
    end

    def find # == refresh
      TextAd.find(:first, :ad_group_id => self.ad_group_id, :id => self.id)
    end

    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      # for ActiveRecord compatibility, we don't use anything besides conditions
      # params for now
      params = params[:conditions] if params[:conditions]

      # we need ad_group_id
      raise ArgumentError, "AdGroup ID is required" unless params[:ad_group_id]
 
      # supported condition parameters: ad_group_id and id
      predicates = [ :ad_group_id, :id ].map do |param_name|
        if params[param_name]
          { :field => param_name.to_s.camelcase, :operator => 'IN', :values => Array( params[param_name] ) }
        end
      end.compact

      selector = {
        :fields => ['Id', 'AdGroupId', 'Headline' ],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }

      response = TextAd.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

      response.map! do |data|
        TextAd.new(data[:ad].merge(:ad_group_id => data[:ad_group_id], :status => data[:status]))
      end

      # TODO convert to TextAd instances
      first_only ? response.first : response
    end

  end
end
