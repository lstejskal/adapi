#
# Provides interface over BudgetOrderService
# Runs on the Adwords API v201206-later
#
#
module Adapi
  class BudgetOrder < Api # == BudgetOrderService

    # PS: id is only read only-value
    ATTRIBUTES = [ :billing_account_id, :id, :spending_limit, :start_date_time, :end_date_time ]

    attr_accessor *ATTRIBUTES

    def attributes
      super.merge Hash[ ATTRIBUTES.map { |k| [k, self.send(k)] } ]
    end

    alias to_hash attributes

    # these fields are required for ADD operation 
    validates_presence_of :billing_account_id, :spending_limit, :start_date_time, :end_date_time

    def initialize(params = {})
      params.symbolize_keys!

      params[:service_name] = :BudgetOrderService
      
      @xsi_type = 'BudgetOrder'

      ATTRIBUTES.each do |param_name|
        self.send("#{param_name}=", params[param_name])
      end

      super(params)
    end

    def create
      return false unless self.valid?      
      
      operand = {
        :billing_account_id => self.send(:billing_account_id),
        :start_date_time => fix_time(self.send(:start_date_time)),
        :end_date_time => fix_time(self.send(:end_date_time))
      }

      if self.send(:spending_limit).is_a?(Hash)
        operand[:spending_limit] = self.send(:spending_limit)
      else
        operand[:spending_limit] = { micro_amount: Api.to_micro_units(self.send(:spending_limit)) }
      end


      pp operand

      response = self.mutate( 
        operator: 'ADD', 
        operand: operand
      )

      check_for_errors(self)

      self.id = response[:value].first[:id] rescue nil
    end

    def update(params = {})

      return false unless self.valid?      
      
      operand = {
        :id => self.send(:id),
        :billing_account_id => self.send(:billing_account_id),
        :start_date_time => fix_time(self.send(:start_date_time)),
        :end_date_time => fix_time(self.send(:end_date_time))
      }
      if self.send(:spending_limit).is_a?(Hash)
        operand[:spending_limit] = self.send(:spending_limit)
      else
        operand[:spending_limit] = { micro_amount: Api.to_micro_units(self.send(:spending_limit)) }
      end

      pp operand
      response = self.mutate(
        operator: 'SET', 
        operand: operand
      )      
      check_for_errors(self)

    end

    def self.find

      select_fields = [
        :billing_account_id, 
        :id, 
        :spending_limit, 
        :start_date_time, 
        :end_date_time
      ].collect{|f| f.to_s.camelize }

      selector = {
        :fields => select_fields,
        :ordering => [],
        :predicates => []
      }

      response = BudgetOrder.new.service.get(selector)      

      response[:entries].collect{|e| BudgetOrder.new(e)}
    end

    def fix_time time
      Time.parse(time.to_s).strftime("%Y%m%d %H%M%S Europe/Prague")
    end

  end
end
