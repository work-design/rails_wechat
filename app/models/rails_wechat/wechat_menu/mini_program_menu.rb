module RailsWechat::WechatMenu::MiniProgramMenu
  extend ActiveSupport::Concern
  included do
    attribute :menu_type, :string, default: 'miniprogram'
  end
  
  def as_json
    {
      type: menu_type,
      name: name,
      key: value
    }
  end

end
