# encoding: utf-8

# This class handles operations with ad_groups
#
# https://developers.google.com/adwords/api/docs/reference/latest/AdGroupService
#
module Adapi
  class AdGroup < Api
  
    ATTRIBUTES = [ :id, :campaign_id, :name, :status, :bids, :bidding_strategy_configuration, :keywords, :ads ]

    attr_accessor *ATTRIBUTES 

    validates_presence_of :campaign_id, :name, :status
    validates_inclusion_of :status, :in => %w{ ENABLED PAUSED DELETED }

    def attributes
      super.merge Hash[ ATTRIBUTES.map { |k| [k, self.send(k)] } ]
    end

    alias to_hash attributes

    def initialize(params = {})
      params[:service_name] = :AdGroupService

      @xsi_type = 'AdGroup'

      ATTRIBUTES.each do |param_name|
        self.send("#{param_name}=", params[param_name]) if params.has_key?(param_name)
      end

      @keywords ||= []

      @ads ||= []

      super(params)
    end



    # convert bids to GoogleApi format
    #
    # can be either string (just xsi_type) or hash (xsi_type with params)
    # although I'm not sure if just string makes sense in this case
    #
    def bids=(params = {})
      @bids = params

      warn "Deprecated - Use bidding_strategy_configuration instead"

      name_translation = {
        "BudgetOptimizerAdGroupBids" => "CpcBid",
        "ConversionOptimizerAdGroupBids" => "CpaBid",
        "ManualCPCAdGroupBids" => "CpcBid",
        "ManualCPMAdGroupBids" => "CpmBid",
        "PercentCPAAdGroupBids" => "PercentCpaBid",
      }

      if @bids

        money = Api.to_micro_units(@bids[:proxy_keyword_max_cpc])
  
        @bidding_strategy_configuration = { 
          :bids => [
            {
              # The 'xsi_type' field allows you to specify the xsi:type of the
              # object being created. It's only necessary when you must provide
              # an explicit type that the client library can't infer.
              :xsi_type => name_translation[@bids[:xsi_type]],
              :bid => {:micro_amount => money},
              :content_bid => {:micro_amount => money}
            }
          ]
        }
      end
    end

    def create
      return false unless self.valid?
      
      operand = Hash[
        [:campaign_id, :name, :status, :bidding_strategy_configuration].map do |k|
          [ k.to_sym, self.send(k) ] if self.send(k)
        end.compact
      ]

      response = self.mutate(
        :operator => 'ADD', 
        :operand => operand
      )

      check_for_errors(self)
      
      self.id = response[:value].first[:id] rescue nil
      
      if @keywords.size > 0
        keyword = Adapi::Keyword.create(
          :ad_group_id => @id,
          :keywords => @keywords
        )
        
        check_for_errors(keyword, :prefix => "Keyword")
      end

      if not @ads.empty?
        ad = Adapi::Ad::TextAd.create( :ads => @ads.map { |ad_data| ad_data.merge(:ad_group_id => @id) } )

        check_for_errors(ad, :prefix => "Ad \"#{ad.headline}\"")
      end

      self.errors.empty?

    rescue AdGroupError => e
      false
    end

    def update(params = {})
      # step 1. update core attributes
      core_attributes = [ :id, :campaign_id, :name, :status, :bids ]
      # get operand in google format 
      # parse the given params by initialize method...
      ad_group = Adapi::AdGroup.new(params)
      # HOTFIX remove :service_name param inserted by initialize method
      params.delete(:service_name)
      # ...and load parsed params back into the hash
      core_params = Hash[ core_attributes.map { |k| [k, ad_group.send(k)] if params[k].present? }.compact ]

      response = ad_group.mutate(
        :operator => 'SET', 
        :operand => core_params.merge( :id => @id, :campaign_id => @campaign_id )
      )

      check_for_errors(ad_group, :store_errors => false)

      # step 2. update keywords
      # delete everything and create new keywords
      if params[:keywords] and not params[:keywords].empty?
        # delete existing keywords
        # OPTIMIZE should be all in one request
        Keyword.find(:all, :ad_group_id => @id).keywords.each do |keyword|
          Keyword.new(:ad_group_id => @id).delete(keyword[:text][:criterion][:id])
        end

        # create new keywords
        result = Adapi::Keyword.create(
          :ad_group_id => @id,
          :keywords => params[:keywords]
        )

        check_for_errors(result, :prefix => "Keyword")        
      end

      # step 3. update ads
      # ads can't be updated, gotta remove them all and add new ads
      if params[:ads] and not params[:ads].empty?
        # remove all existing ads
        # TODO change into class method
        existing_ads = self.find_ads
        ad = existing_ads.first.delete(
          :ad_group_id => @id,
          :ad_ids => existing_ads.map { |ad| ad.id }
        )

        unless ad
          # REFACTOR
          self.errors.add(:base, add.errors.full_messages)
          return false 
        end

=begin
        self.find_ads.each do |ad| 
          unless ad.destroy
            self.errors.add("Ad \"#{ad.headline}\"", ["cannot be deleted"])
            return false 
          end
        end
=end
        # create new ads
        ad = Adapi::Ad::TextAd.create( :ads => params[:ads].map { |ad_data| ad_data.merge(:ad_group_id => @id) } )

        check_for_errors(ad, :prefix => "Ad \"#{ad.headline}\"")
      end

      self.errors.empty?

    rescue AdGroupError => e
      false
    end
 
    # PS: perhaps also change the ad_group name when deleting
    def delete
      update(:status => 'DELETED')  
    end

    def self.find(amount = :all, params = {})
      params.symbolize_keys!
      first_only = (amount.to_sym == :first)
      # by default, exclude ad_groups with status DELETED
      params[:status] ||= %w{ ENABLED PAUSED }

      raise "Campaign ID is required" unless params[:campaign_id]
      
      predicates = [ :campaign_id, :id, :name, :status ].map do |param_name|
        if params[param_name].present?
          {:field => param_name.to_s.camelcase, :operator => 'IN', :values => Array( params[param_name] ) }
        end
      end.compact

      select_fields = %w{ Id CampaignId Name Status } 
      # add Bids atributes
      select_fields += %w{ EnhancedCpcEnabled ProxyKeywordMaxCpc 
        KeywordMaxCpc KeywordContentMaxCpc }

      selector = {
        :fields => select_fields,
        :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => predicates
      }

      response = AdGroup.new.service.get(selector)

      ad_groups = (response and response[:entries]) ? response[:entries] : []

      ad_groups = ad_groups.slice(0,1) if first_only

      # find keywords and ads
      ad_groups.map! do |ad_group|
        ad_group.merge(
          :keywords => Keyword.shortened(Keyword.find(:all, :ad_group_id => ad_group[:id]).keywords),
          :ads => Ad::TextAd.find(:all, :ad_group_id => ad_group[:id]).map(&:to_hash) 
        )
      end

      ad_groups.map! { |ad_group| AdGroup.new(ad_group) }

      first_only ? ad_groups.first : ad_groups
    end

    def find_keywords(first_only = false)
      Keyword.find( (first_only ? :first : :all), :ad_group_id => self.id )
    end

    # TODO find all types of ads
    def find_ads(first_only = false)
      Ad::TextAd.find( (first_only ? :first : :all), :ad_group_id => self.id )
    end

  end
end
