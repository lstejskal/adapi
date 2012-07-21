# encoding: utf-8

module Adapi

  # Ad == AdGroupAd
  # wraps all types of ads: text ads, image ads...
  class Ad < Api

    # REFACTOR attributes

    attr_accessor :id, :ad_group_id, :url, :display_url, :approval_status,
      :disapproval_reasons, :trademark_disapproved

    validates_presence_of :ad_group_id

    # PS: create won't work with id and ad_group_id
    # 'id' => id, 'ad_group_id' => ad_group_id, 
    def attributes
      super.merge( 'id' => id, 'ad_group_id' => ad_group_id, 
        'url' => url, 'display_url' => display_url )
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupAdService

      %w{ id ad_group_id url display_url status }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    # deletes ad
    #
    def destroy
      response = self.mutate(
        :operator => 'REMOVE',
        :operand => {
          :ad_group_id => @ad_group_id,
          :ad => { :id => @id, :xsi_type => 'Ad' }
        }
      )

      (response and response[:value]) ? true : false
    end

    # ad-specific mutate wrapper, deals with PolicyViolations for ads
    #
    def mutate(operation)
      operation = [operation] unless operation.is_a?(Array)
      
      # fix to save space during specifyng operations
      operation = operation.map do |op|
        op[:operand].delete(:status) if op[:operand][:status].nil?
        op
      end
      
      begin
        
        response = @service.mutate(operation)

      rescue *API_EXCEPTIONS => e

        # return PolicyViolations in specific format so they can be sent again
        # see adwords-api gem example for details: handle_policy_violation_error.rb
        e.errors.each do |error|
          # error[:xsi_type] seems to be broken, so using also alternative key
          # also could try: :"@xsi:type" (but api_error_type seems to be more robust)
          if (error[:xsi_type] == 'PolicyViolationError') || (error[:api_error_type] == 'PolicyViolationError')
            if error[:is_exemptable]
              self.errors.add(:PolicyViolationError, error[:key])
            end

            # return also exemptable errors, operation may fail even with them
            self.errors.add(:base, "violated %s policy: \"%s\" on \"%s\"" % [
              error[:is_exemptable] ? 'exemptable' : 'non-exemptable', 
              error[:key][:policy_name], 
              error[:key][:violating_text]
            ])
          else
            self.errors.add(:base, e.message)
          end
        end # of errors.each
      end

      response
    end

  end
end
