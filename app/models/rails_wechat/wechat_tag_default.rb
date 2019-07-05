module RailsWechat::WechatTagDefault
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :default_type, :string
    
    has_many :wechat_tags, dependent: :nullify
    after_save :sync_name, if: -> { saved_change_to_name? }
  end

  def sync_name
    wechat_tags.where(name: name_before_last_save).update_all(name: self.name)
  end
  
end

