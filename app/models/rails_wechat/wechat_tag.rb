module RailsWechat::WechatTag
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
  end
  
  def sync_to_wechat
    ::WechatApp.default_where(organ_id: self.organ_id).map do |wechat_config|
      wechat_config.api.tag_create(self.name)
    end
  end

end

