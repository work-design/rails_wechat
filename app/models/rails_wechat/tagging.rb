module RailsWechat::Tagging
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    
    has_one :wechat_tag, as: :tagging, dependent: :nullify
    has_many :wechat_tags, as: :tagging, dependent: :nullify
  end

  def wechat_tag
    super || create_wechat_tag(wechat_app_id: wechat_app.id)
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
