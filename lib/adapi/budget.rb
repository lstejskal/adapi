# encoding: utf-8

module Adapi

  # Budget
  # wraps budget of campaign
  class Budget < Api

    attr_accessor :budget_id, :period, :amount, :delivery_method, :name

    def initialize(params = {})
      params[:service_name] = :BudgetService

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
            :period => self.period,
            :amount => self.amount,
            :name => self.name,
            :delivery_method => self.delivery_method,
          }
        }

      response = self.mutate(operation)
      check_for_errors(self)

      self.budget_id = response[:value].first[:budget_id] rescue nil

    end
  end
end
