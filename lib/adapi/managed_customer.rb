#
# Provides interface over ManagedCustomerService (formerly ServicedAccountService). 
# Runs on the Adwords API v201206
#
# This model use :customer_id instead of :id
#
module Adapi
  class ManagedCustomer < Api # == Account

    # PS: lots of these attributes are read-only
    ATTRIBUTES = [ :name, :login, :company_name, :customer_id, 
      :can_manage_clients, :currency_code, :date_time_zone ]

    attr_accessor *ATTRIBUTES

    def attributes
      super.merge Hash[ ATTRIBUTES.map { |k| [k, self.send(k)] } ]
    end

    alias to_hash attributes

    # these fields are required for ADD operation 
    validates_presence_of :name, :currency_code, :date_time_zone

    def initialize(params = {})
      params.symbolize_keys!

      params[:service_name] = :ManagedCustomerService
      
      # this model uses the latest version of AdWords API. 
      # the rest of the model still use v201109_1 
      params[:api_version] = :v201206

      @xsi_type = 'ManagedCustomer'

      ATTRIBUTES.each do |param_name|
        self.send("#{param_name}=", params[param_name])
      end

      super(params)
    end

    def create
      return false unless self.valid?      
      
      operand = Hash[
        [ :name, :currency_code, :date_time_zone ].map do |k|
          [ k.to_sym, self.send(k) ] if self.send(k)
        end.compact
      ]

      response = self.mutate( 
        operator: 'ADD', 
        operand: operand
      )

      check_for_errors(self)

      self.id = self.customer_id = response[:value].first[:customer_id] rescue nil
    end

    def self.find(amount = :first, params = {})
      # find single campaign by id
      if params.empty? and not amount.is_a?(Symbol)
        params[:customer_id] = amount.to_i
        amount = :first
      end

      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      # create predicate from supported search parameters
      predicates = [ :name, :customer_id, :currency_code ].map do |param_name|
        if params[param_name]
          { :field => param_name.to_s.camelcase, :operator => 'IN', :values => Array( params[param_name] ) }
        end
      end.compact

      # REFACTOR take fields from attributes using some common method
      select_fields = %w{ Name Login companyName customerId 
        canManageClients currencyCode dateTimeZone }

      selector = {
        :fields => select_fields,
        # :ordering => [ { field: 'Name', sort_order: 'ASCENDING' } ],
        :predicates => predicates
      }

      response = ManagedCustomer.new.service.get(selector)

      response = (response and response[:entries]) ? response[:entries] : []

#      response.map! do |data|
#        ManagedCustomer.new(data.merge( :customer_id => data[:customer_id] )
#        TextAd.new(data[:ad].merge(:ad_group_id => data[:ad_group_id], :status => data[:status]))
#      end

      first_only ? response.first : response
    end

  end
end
