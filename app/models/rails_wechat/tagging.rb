module RailsWechat::Tagging
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    
    has_one :wechat_tag, as: :tagging, dependent: :destroy
    after_save_commit :sync_wechat_tag, if: -> { saved_change_to_name? }
  end

  def sync_wechat_tag
    _wechat_app = wechat_app
    return unless _wechat_app
    wt = wechat_tag || build_wechat_tag(wechat_app_id: _wechat_app.id)
    wt.name = self.name
    wt.save
  end
  
  def wechat_app
    if self.respond_to? :organ_id
      _organ_id = organ_id
    else
      _organ_id = nil
    end
    
    if WechatApp.column_names.include?('organ_id')
      WechatApp.find_by(organ_id: _organ_id, primary: true)
    else
      WechatApp.find_by(primary: true)
    end
  end
  
end
