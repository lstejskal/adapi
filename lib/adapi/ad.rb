module Adapi

  # Ad == AdGroupAd
  class Ad < Api

    attr_accessor :ad_group_id, :url, :display_url

    validates_presence_of :ad_group_id

    def attributes
      { 'ad_group_id' => ad_group_id, 'url' => url, 'display_url' => display_url }
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupAdService

      %w{ ad_group_id url display_url }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

    def self.create(params = {})
      ad_service = Ad.new

      ad_group_id = params[:data].delete(:ad_group_id)

      operation = { :operator => 'ADD', 
        :operand => { :ad_group_id => ad_group_id, :ad => params[:data] }
      } 
    
      response = ad_service.service.mutate([operation])

      ad_group = response[:value].first

      ad = nil
      if response and response[:value]
        ad = response[:value].first
        puts "  Ad ID is #{ad[:ad][:id]}, type is '#{ad[:ad][:xsi_type]}' and status is '#{ad[:status]}'."
      end

      ad
    end

    def self.find(params = {})
      ad_service = Ad.new

      raise "No AdGroup ID" unless params[:ad_group_id]
      ad_group_id = params[:ad_group_id].to_i

      selector = {
        :fields => ['Id', 'Headline'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :predicates => [
          {:field => 'AdGroupId', :operator => 'EQUALS', :values => ad_group_id }
          # { :field => 'Status', :operator => 'IN', :values => ['ENABLED', 'PAUSED', 'DISABLED'] }
        ]
      }

      response = ad_service.service.get(selector)

      if response and response[:entries]
        ads = response[:entries]
        puts "Ad group ##{ad_group_id} has #{ads.length} ad(s)."
        ads.each do |ad|
          puts "  Ad id is #{ad[:ad][:id]}, type is #{ad[:ad][:xsi_type]} and " +
              "status is \"#{ad[:status]}\"."
        end
      else
        puts "No ads found for ad group ##{ad_group_id}."
      end
    end

  end
end
