module Wechat
  module Model::Menu::ScanPushMenu

    def as_json
      {
        type: 'scancode_push',
        name: name,
        key: value
      }
    end

  end
end
