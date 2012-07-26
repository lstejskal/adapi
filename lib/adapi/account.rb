
module Adapi
  class Account < Api

    # PS: lots of these attributes are read-only
    # old: descriptive_name, new: name
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

      # HOTFIX
      params[:service_name] = :CreateAccountService
      @xsi_type = 'CreateAccount'

      ATTRIBUTES.each do |param_name|
        self.send("#{param_name}=", params[param_name])
      end

      super(params)
    end

    def create
      params[:service_name] = :CreateAccountService
      @xsi_type = 'CreateAccount'

      return false unless self.valid?      
      
      operand = Hash[
        [ :currency_code, :date_time_zone ].map do |k|
          [ k.to_sym, self.send(k) ] if self.send(k)
        end.compact
      ]

      response = self.mutate( 
        operator: 'ADD', 
        operand: operand,
        :descriptive_name => params[:name]
      )

      check_for_errors(self)

      self.id = self.customer_id = response.first[:customer_id] rescue nil
    end

=begin
    def self.find(amount = :first, params = {})
      # find single campaign by id
      if params.empty? and not amount.is_a?(Symbol)
        params[:customer_id] = amount.to_i
        amount = :first
      end

      params.symbolize_keys!
      first_only = (amount.to_sym == :first)

      params[:customer_id] = params.delete(:customer_ids) if params[:customer_ids]
      params[:customer_id] = params.delete(:id) if params[:id]

      # create predicate from supported search parameters
      selector = { :customer_ids => Array( params[:customer_id] ) }

      search_instance = Account.new(:service_name => :ServicedAccountService)
      search_instance.xsi_type = 'ServicedAccount'

      response = search_instance.service.get(selector)

      return response

      response = (response and response[:entries]) ? response[:entries] : []

      first_only ? response.first : response
    end
=end

  end
end
