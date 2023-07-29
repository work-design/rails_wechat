module Wechat
  module Model::Menu::MiniProgramMenu

    def as_json(options = nil)
      {
        type: 'miniprogram',
        name: name,
        url: value,
        appid: mp_appid,
        pagepath: mp_pagepath
      }
    end

  end
end
