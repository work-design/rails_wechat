module RailsWechat::WechatMenu::ViewMenu
  extend ActiveSupport::Concern
  included do
    attribute :menu_type, :string, default: 'view'
  end
  
  def as_json
    {
      type: menu_type,
      name: name,
      url: value
    }
  end

end
