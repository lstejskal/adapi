module Adapi

  # Ad == AdGroupAd
  # wraps all types of ads: text ads, image ads...
  class Ad < Api

    attr_reader :approval_status, :disapproval_reasons, :trademark_disapproved,
      :xsi_type

    attr_accessor :id, :ad_group_id, :url, :display_url

    validates_presence_of :ad_group_id

    # PS: create won't work with id and ad_group_id
    # 'id' => id, 'ad_group_id' => ad_group_id, 
    def attributes
      { 'xsi_type' => xsi_type, 'url' => url, 'display_url' => display_url }
    end

    def initialize(params = {})
      params[:service_name] = :AdGroupAdService

      %w{ id ad_group_id url display_url }.each do |param_name|
        self.send "#{param_name}=", params[param_name.to_sym]
      end

      super(params)
    end

  end
end
