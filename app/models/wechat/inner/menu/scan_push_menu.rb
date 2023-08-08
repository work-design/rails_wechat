module Wechat
  module Inner::Menu::ScanPushMenu

    def as_json(options = nil)
      {
        type: 'scancode_push',
        name: name,
        key: value
      }
    end

  end
end
