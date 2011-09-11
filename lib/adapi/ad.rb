module Adapi

  # Ad == AdGroupAd
  # wraps all types of ads: text ads, image ads...
  class Ad < Api

    attr_accessor :ad_group_id, :url, :display_url, :approval_status,
      :disapproval_reasons, :trademark_disapproved

    validates_presence_of :ad_group_id

    # PS: create won't work with id and ad_group_id
    # 'id' => id, 'ad_group_id' => ad_group_id, 
    def attributes
      super.merge('url' => url, 'display_url' => display_url)
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
          :ad_group_id => self.ad_group_id,
          :ad => { :id => self.id, :xsi_type => 'Ad' }
        }
      )

      (response and response[:value]) ? true : false
    end

  end
end
