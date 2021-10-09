module Wechat
  module Model::Menu::ScanWaitMenu

    def as_json
      {
        type: 'scancode_waitmsg',
        name: name,
        key: value
      }
    end

  end
end
