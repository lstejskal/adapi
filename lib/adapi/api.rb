# encoding: utf-8

# Basic adapi class, parent of all service classes

# TODO create universal Api.attributes method (instead of having the same method in all subclasses)
# TODO create universal Api.initialize method (some subclasses don't have to have their own initialize method)
# TODO move common methods into separate Common class or module

module Adapi
  class Api
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    LOGGER = Config.setup_logger

    API_EXCEPTIONS = [
      AdsCommon::Errors::ApiException, 
      AdsCommon::Errors::HttpError, 
      AdwordsApi::Errors::ApiException
    ]

    # these exceptions help to control program flow
    # during complex operations over campaigns and ad_groups
    # 
    class ApiError < Exception; end
    class CampaignError < Exception; end
    class AdGroupError < Exception; end

    attr_accessor :adwords, :service, :version, :params,
      :id, :status, :xsi_type

    # Returns hash of attributes for a model instance
    #
    # This is an implementation of ActiveRecord::Base#attributes method.
    # Children of API model customize this method for their own attributes.
    #
    def attributes
      { status: status, xsi_type: xsi_type }
    end

    def initialize(params = {})
      params.symbolize_keys!

      raise "Missing Service Name" unless params[:service_name]

      @adwords = params[:adwords_api_instance]

      # REFACTOR
      unless @adwords
        @adwords = AdwordsApi::Api.new(Adapi::Config.read)

        authentication_method = Adapi::Config.read[:authentication][:method].to_s.upcase

        case authentication_method
        when "CLIENTLOGIN", "OAUTH"
          warn "#{authentication_method} is nearly obsolete, please update to OAuth2"
        when "OAUTH2_JWT"
          raise "OAUTH2_JWT is not yet implemented, please use OAUTH2 instead"
        # authorize to oauth2
        when "OAUTH2"

          if Adapi::Config.read[:authentication][:oauth2_refresh_token]
            RefreshToken.get_access_token Adapi::Config.read
            @adwords = AdwordsApi::Api.new(Adapi::Config.read)
          else
            oauth2_token = Adapi::Config.read[:authentication][:oauth2_token]
            if oauth2_token.nil? || oauth2_token.class != Hash 
              raise "Missing or invalid OAuth2 token"
            end

            @adwords.authorize({:oauth2_verification_code => $token})
          end
        end
      end

      @adwords.logger = LOGGER if LOGGER
      @version = API_VERSION
      @service = @adwords.service(params[:service_name].to_sym, @version)
      @params = params
    end

    def to_param
      self[:id]
    end

    def persisted?
      false
    end

    # FIXME hotfix, should be able to sort it out better through ActiveModel
    def [](k)
      self.send(k)
    end

    def []=(k,v)
      self.send("#{k}=", v)
    end

    alias :to_hash :attributes

    # detects whether the instance has been saved already
    #
    def new?
      self.id.blank?
    end

    def self.create(params = {})
      # FIXME deep symbolize_keys, probably through ActiveSupport
      params.symbolize_keys! if params.is_a?(Hash)

      api_instance = self.new(params)
      api_instance.create
      api_instance
    end

    # done mostly for campaign, probably won't work pretty much anywhere else
    # which can be easily fixed creating by self.update method for specific
    # class
    #
    def self.update(params = {})
      params.symbolize_keys!

      # PS: updating campaign without finding it is much faster
      api_instance = self.new()
      api_instance.id = params.delete(:id)
      api_instance.errors.add('id', 'is missing') unless api_instance.id
      
      api_instance.update(params)
      api_instance
    end

    # wrap AdWords add/update/destroy actions and deals with errors
    # PS: Keyword and Ad models have their own wrappers because of
    # PolicyViolations
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

        unless e.respond_to?(:errors)
          self.errors.add(:base, e.message)
          return false
        end

        e.errors.each do |error|
          if (error[:xsi_type] == 'PolicyViolationError') || (error[:api_error_type] == 'PolicyViolationError')
            # return exemptable PolicyViolations errors in custom format so we can request exemptions
            # see adwords-api gem example for details: handle_policy_violation_error.rb
            # so far, this applies only for keywords and ads
            if error[:is_exemptable]
              self.errors.add( :PolicyViolationError, error[:key].merge(
                :operation_index => AdwordsApi::Utils.operation_index_for_error(error)
              ) )
            end

            # besides PolicyViolations errors in custom format, return all errors also in regular format
            self.errors.add(:base, "violated %s policy: \"%s\" on \"%s\"" % [
              error[:is_exemptable] ? 'exemptable' : 'non-exemptable', 
              error[:key][:policy_name], 
              error[:key][:violating_text]
            ])
          else
            self.errors.add(:base, e.message)
          end
        end # of errors.each

        false
      end
      
      response
    end

    # Deals with campaign exceptions encountered during complex operations over AdWords API
    # 
    # Parameters:
    # store_errors (default: true) - add errors to self.error collection
    # raise_errors (default: false) - raises exception CampaignError (after optional saving errors)
    #
    def check_for_errors(adapi_instance, options = {})
      options.merge!( store_errors: true, raise_errors: false )

      # don't store errors in this case, because errors are already there
      # and loop in store_errors method would cause application to hang
      options[:store_errors] = false if (adapi_instance == self)

      unless adapi_instance.errors.empty?
        store_errors(adapi_instance, options[:prefix]) if options[:store_errors]

        if options[:raise_errors]
          exception_type = case adapi_instance.xsi_type
            when "Campaign" then CampaignError
            when "AdGroup" then AdGroupError
            else ApiError
          end

          raise exception_type
        end
      end
    end

    # Shortcut for pattern used in Campaign#update method 
    # When partial update fails, store errors in main campaign instance 
    #
    def store_errors(failed_instance, error_prefix = nil)
      raise "#{failed_instance.xsi_type}#store_errors: Invalid object instance" unless failed_instance.respond_to?(:errors)

      error_prefix ||= failed_instance.respond_to?(:xsi_type) ? failed_instance.xsi_type : nil

      failed_instance.errors.messages.each_pair do |k, v|
          k = "#{error_prefix}::#{k}" if error_prefix and (k != :base)

          Array(v).each do |x| 
            self.errors.add(k, x)
          end
      end
    end

    # convert number to micro units (unit * one million)
    #
    def self.to_micro_units(x)
      (x.to_f * 1e6).to_i
    end

  end
end
