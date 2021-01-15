module Wechat
  module Model::WechatMenu::MiniProgramMenu
    extend ActiveSupport::Concern

    included do
      attribute :menu_type, :string, default: 'miniprogram'
    end

    def as_json
      {
        type: menu_type,
        name: name,
        url: value,
        appid: mp_appid,
        pagepath: mp_pagepath
      }
    end

  end
end
