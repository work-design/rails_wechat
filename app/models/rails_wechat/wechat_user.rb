module RailsWechat::WechatUser
  extend ActiveSupport::Concern
  included do
    belongs_to :wechat_app, foreign_key: :app_id, primary_key: :appid
    
    has_many :wechat_requests, dependent: :delete_all
    has_many :ticket_items, dependent: :delete_all
    has_many :wechat_user_tags, dependent: :destroy
    has_many :wechat_tags, through: :wechat_user_tags
    
    after_save_commit :sync_default_wechat_tag, if: -> { saved_change_to_app_id? }
  end
  
  def sync_default_wechat_tag
    wechat_tag_default = WechatTagDefault.find_by(default_type: self.class.name)
    tag = wechat_app.wechat_tags.find_by(wechat_tag_default_id: wechat_tag_default.id)
    
    self.wechat_user_tags.create(tag_id: tag.id)
  end
  
end
