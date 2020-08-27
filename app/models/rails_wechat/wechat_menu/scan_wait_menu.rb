module RailsWechat::WechatMenu::ScanWaitMenu
  extend ActiveSupport::Concern

  included do
    attribute :menu_type, :string, default: 'scancode_waitmsg'
  end

  def as_json
    {
      type: menu_type,
      name: name,
      key: value
    }
  end

end
