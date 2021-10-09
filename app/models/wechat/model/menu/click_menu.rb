module Wechat
  module Model::Menu::ClickMenu

    def as_json
      {
        type: 'click',
        name: name,
        key: value
      }
    end

  end
end
