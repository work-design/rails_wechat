module RailsWechat::WechatTag
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :count, :integer, default: 0
    
    belongs_to :wechat_tag_default, optional: true
    belongs_to :wechat_app
    
    validates :name, uniqueness: { scope: :wechat_app_id }
    
    after_create_commit :sync_to_wechat, if: -> { tag_id.blank? }
    after_destroy_commit :remove_from_wechat, if: -> { tag_id.present? }
  end
  
  def sync_to_wechat
    wechat_app.api.tag_create(self.name)
  end
  
  def remove_from_wechat
    wechat_app.api.tag_delete(self.tag_id)
  end

end

