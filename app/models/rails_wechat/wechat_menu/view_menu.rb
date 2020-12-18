module RailsWechat::WechatMenu::ViewMenu
  extend ActiveSupport::Concern

  included do
    attribute :menu_type, :string, default: 'view'
    after_initialize if: :new_record? do
      self.value ||= host
    end
  end

  def as_json
    {
      type: menu_type,
      name: name,
      url: value
    }
  end

  def host
    organ = wechat_app&.organ
    if organ
      organ.host
    else
      ''
    end
  end

end
