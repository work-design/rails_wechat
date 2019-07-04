module RailsWechat::WechatTag
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    
    belongs_to :wechat_tag_default, optional: true
    belongs_to :wechat_app
    
    after_create_commit :sync_to_wechat
    after_destroy_commit :remove_from_wechat
  end
  
  def sync_to_wechat
    wechat_app.api.tag_create(self.name)
  end
  
  def remove_from_wechat
    wechat_app.api.tag_create(self.name)
  end

end

