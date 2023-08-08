module Wechat
  module Inner::Menu::ScanWaitMenu

    def as_json(options = nil)
      {
        type: 'scancode_waitmsg',
        name: name,
        key: value
      }
    end

  end
end
