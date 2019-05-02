module RailsWechat::WechatMenu::ClickMenu
  extend ActiveSupport::Concern
  included do
    attribute :menu_type, :string, default: 'click'
  end
  
  def as_json
  
  end

end
