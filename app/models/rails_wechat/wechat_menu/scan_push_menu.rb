module RailsWechat::WechatMenu::ScanPushMenu
  extend ActiveSupport::Concern

  included do
    attribute :menu_type, :string, default: 'scancode_push'
  end

  def as_json
    {
      type: menu_type,
      name: name,
      key: value
    }
  end

end
