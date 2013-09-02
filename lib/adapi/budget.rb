# encoding: utf-8

module Adapi

  # Budget
  # wraps budget of campaign
  class Budget < Api

    attr_accessor :budget_id, :period, :amount, :delivery_method, :name

    def initialize(params = {})
      params[:service_name] = :BudgetService
      @xsi_type = 'BudgetService'

      %w{ budget_id period amount delivery_method name }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def create
      operation = 
        {
          :operator => 'ADD', 
          :operand => {
            :xsi_type => 'Budget',
            :period => self.period || "DAILY",
            :amount => self.amount,
            :name => self.name,
            :delivery_method => self.delivery_method || "STANDARD",
          }
        }

      response = self.mutate(operation)
      check_for_errors(self)

      self.budget_id = response[:value].first[:budget_id] rescue nil

    end


    def update(params = {})
      @service = @adwords.service(:BudgetService, @version)

      operand = {
        :budget_id => params[:budget_id]
      }

      [:period, :amount, :name, :delivery_method].each do |key|
        operand[key] = params[key] if params.has_key?(key)
      end

      if operand[:amount] and not operand[:amount].is_a?(Hash)
        operand[:amount] = { micro_amount: Api.to_micro_units(operand[:amount]) }
      end

      operation = 
      {
        :operator => 'SET', 
        :operand => operand
      }

      response = self.mutate(operation)

      check_for_errors(self)

      self.budget_id = response[:value].first[:budget_id] rescue nil
    end

  end
end
