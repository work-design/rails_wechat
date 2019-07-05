module RailsWechat::WechatTag
  SYS_TAG = ['2'].freeze
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :count, :integer, default: 0
    
    belongs_to :wechat_tag_default, optional: true
    belongs_to :wechat_app
    
    validates :name, uniqueness: { scope: :wechat_app_id }
    
    before_create :sync_name
    after_create :sync_to_wechat, if: -> { tag_id.blank? }
    after_destroy_commit :remove_from_wechat, if: -> { tag_id.present? }
  end
  
  def sync_name
    self.name = wechat_tag_default.name if wechat_tag_default
  end
  
  def sync_to_wechat
    r = wechat_app.api.tag_create(self.name)
    tag = r['tag']
    self.tag_id = tag['id']
    self.save
  end
  
  def remove_from_wechat
    wechat_app.api.tag_delete(self.tag_id)
  end
  
  def can_destroy?
    SYS_TAG.include?(tag_id)
  end

end

