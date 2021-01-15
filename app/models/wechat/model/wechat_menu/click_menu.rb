module Wechat
  module Model::WechatMenu::ClickMenu
    extend ActiveSupport::Concern

    included do
      attribute :menu_type, :string, default: 'click'
    end

    def as_json
      {
        type: menu_type,
        name: name,
        key: value
      }
    end

  end
end
