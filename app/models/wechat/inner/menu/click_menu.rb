module Wechat
  module Inner::Menu::ClickMenu

    def as_json(options = nil)
      {
        type: 'click',
        name: name,
        key: value
      }
    end

  end
end
